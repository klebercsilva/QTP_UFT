'--------------------------------------------------------------------------------------------'
' Library with useful functions for data manipulation for QTP/UFT '
' @author: Kleber Silva'
' @date: 02/15/2017'
'--------------------------------------------------------------------------------------------'
Option Explicit
'--------------------------------------------------------------------------------------------'
'Function name: GetRowIndexByItemName'
'Author: Kleber Silva'
'Creation Date: 01/20/2017'
'Description: Return the index of a given row in a datagrid object'
'--------------------------------------------------------------------------------------------'
Public Function GetRowIndexByItemName (ColumnName, Value)	
	Dim RowCount, RowVal, RowIndex, I

	If Not IsNull(ColumnName) And Not IsNull(Value) Then

		RowCount = SwfWindow("Dealing Panel").SwfTable("dgvBoletosCompulsorios").RowCount
		
		With SwfWindow("Dealing Panel").SwfTable("dgvBoletosCompulsorios")
		
			For  I = 1 To RowCount -1
				RowVal = .GetCellData(I, ColumnName)	
				
				If RowVal = Value Then
					RowIndex = I
					GetRowIndexByItemName = RowIndex
					Exit For
					Exit Function
				Else
					GetRowIndexByItemName = Null
				End If
			Next

			If IsNull(GetRowIndexByItemName) Then
				MsgBox "Não foi possível encontrar o índice no datagrid. " & _
							"Verifique se os dados informados estão corretos e tente novamente.", _
							 	16, "Mensagem da Automação"
					
				Exit Function
			End If

		End With
	Else
		MsgBox "Atenção, verifique se os parâmetros informados estão corretos e tente novamente", _
					16, "Mensagem de Automação"
		ExitTest
	End If

End Function

'--------------------------------------------------------------------------------------------'
'Function name: SelectRowByItemName'
'Author: Kleber Silva'
'Creation Date: 01/20/2017'
'Description: Select and click cell in a datagrid object'
'--------------------------------------------------------------------------------------------'
Public Sub SelectRowByItemName (ColumnName, ItemName)
	
	Dim RowIndex : RowIndex = GetRowIndexByItemName(ColumnName, ItemName)
	
	If Not IsNull(RowIndex) And RowIndex <> CInt("0") Then
		With SwfWindow("Dealing Panel").SwfTable("dgvBoletosCompulsorios")
			.ActivateCell RowIndex, ColumnName
		End With
	Else
		MsgBox "Não foi possível selecionar o valor no datagrid. " & _
					"Verifique se os dados informados estão corretos e tente novamente.", _ 
						16, "Mensagem da Automação"

		'QTP Function to exit the test in case no value has been found'
		ExitTest
	End If
	
End Sub

'--------------------------------------------------------------------------------------------'
'Function name: ReadExcelFileToArray'
'Author: Kleber Silva'
'Creation Date: 03/02/2017'
'Description: Read XLS file and returns a multidimensional array of rows and columns'
'--------------------------------------------------------------------------------------------'
Public Function ReadExcelFileToArray (strFilePath, strSheetName)

	Const adCmdStoredProc = 4

	Dim objConn, objRes, objFSO, strQuery, i

	Set objConn = CreateObject("ADODB.Connection")
	Set objFSO = CreateObject("Scripting.FileSystemObject")

	If Not IsNull(strSheetName) And objFSO.FileExists(strFilePath) Then
		If Not IsNull(strSheetName) And SheetExists(strFilePath, strSheetName) Then		
			With objConn
				.Provider = "Microsoft.ACE.OLEDB.12.0"
				.ConnectionString = "Data Source=" & strFilePath & ";Extended Properties=""Excel 12.0 Xml; HDR=No;IMEX=1"""
				.Open
			End With

			strQuery = "SELECT * FROM [" & strSheetName & "$]"
									
			Set objRes = objConn.Execute(strQuery, adCmdStoredProc)

			If Not objRes.EOF Then
				Dim arrRecords
				arrRecords = objRes.GetRows
				
				'Return of the function
				ReadExcelFileToArray = arrRecords
				
				'Destroy variables'			
				Set objRes = Nothing
				objConn.Close
				Set objConn = Nothing
				Exit Function
			Else
				MsgBox "Não foi possível ler os dados do arquivo: " & strFilePath(UBound(strFilePath)) & ".", 16, "Mensagem da Automação"
				ReadExcelFileToArray = Null
				Exit Function
			End If
		Else
			MsgBox "Não foi possível encontrar a sheet: " & strSheetName & ".", 16, "Mensagem da Automação"
			ReadExcelFileToArray = Null
			Exit Function
		End If
	Else
		MsgBox "Não foi possível encontrar o arquivo: " & strFilePath & ".", 16, "Mensagem da Automação"
		ReadExcelFileToArray = Null
		Exit Function
	End If

End Function

'--------------------------------------------------------------------------------------------'
'Function name: SheetExists
'Author: Kleber Silva
'Creation Date: 03/02/2017'
'Description: Check if sheet exists
'--------------------------------------------------------------------------------------------'
Public Function SheetExists (strFilePath, strSheetName)
	Dim objXl, worksheet
	Set objXl = CreateObject("Excel.Application")
	
	objXl.Application.Visible = False
	
	objXl.WorkBooks.Open strFilePath

	For Each worksheet In objXl.WorkBooks(1).WorkSheets
		If worksheet.Name = strSheetName Then
			SheetExists = True
		End If
	Next

	objXl.DisplayAlerts = False
	objXl.WorkBooks.Close

	objXl.Quit
	Set objXl = Nothing

End Function

'--------------------------------------------------------------------------------------------'
'Function name: TakeScreenshot'
'Author: Kleber Silva'
'Creation Date: 06/02/2017'
'Description: Take a screenshot of the current area'
'--------------------------------------------------------------------------------------------'
Public Sub TakeScreenshot (objControl)
	
	Dim strFileName, strPathToSave
	Dim strDateFormat, strTimeFormat, strDateTimeFormat
	
	objControl.Activate
	
	strFileName = Window("ForeGround:=True").GetROProperty("Title")
	strDateFormat = Replace(FormatDateTime(Date(), 2), "/", "_")
	strTimeFormat = Replace(FormatDateTime(Time(), 3), ":", "_")
	strDateTimeFormat = strDateFormat & "_" & strTimeFormat
	strPathToSave = Environment.Value("PathToSaveEvidence") & "\" & strFileName & "_" & strDateTimeFormat & ".png"
	
	If IsNull(strFileName) Then
		'Default file name in case window title cannot be retrieved'
		strFileName = "Screenshot"
	End If
	
	If Not IsNull(objControl) Then
		objControl.CaptureBitmap strPathToSave, True
	Else
		'Default object {Captures the entire screen}'
		Desktop.CaptureBitmap strPathToSave, True
	End If
	
End Sub

'--------------------------------------------------------------------------------------------'
'Function name: CheckColumnNames'
'Author: Kleber Silva'
'Creation Date: 02/15/2017'
'Description: Check column names within a given XLS file'
'--------------------------------------------------------------------------------------------'
Public Function CheckColumnNames()
	Dim i, strColumnName

	For i = 0 To UBound(arr)
		Select Case arr(i, 0)
			Case "CONTROL_ID"
				strColumnName = strColumnName & "CONTROL_ID" & ";"
			Case "TIPO_OPERACAO"
				strColumnName = strColumnName & "TIPO_OPERACAO" & ";"			
			Case "TIPO_MOEDA"
				strColumnName = strColumnName & "TIPO_MOEDA" & ";"
			Case "VALOR_OPERACAO"
				strColumnName = strColumnName & "VALOR_OPERACAO" & ";"
			Case "TIPO_ID_CLIENTE"
				strColumnName = strColumnName & "TIPO_ID_CLIENTE" & ";"
			Case "NRO_ID_CLIENTE"
				strColumnName = strColumnName & "NRO_ID_CLIENTE" & ";"
			Case "FORMA_PAGAMENTO_ME"
				strColumnName = strColumnName & "FORMA_PAGAMENTO_ME" & ";"
			Case "FORMA_PAGAMENTO_MN"
				strColumnName = strColumnName & "FORMA_PAGAMENTO_MN" & ";"
			Case "CNPJ_CORRETORA"
				strColumnName = strColumnName & "CNPJ_CORRETORA" & ";"
			Case "MODALIDADE_PAGAMENTO"
				strColumnName = strColumnName & "MODALIDADE_PAGAMENTO" & ";"
			Case "TIPO_EDICAO_CONTRATO"
				strColumnName = strColumnName & "TIPO_EDICAO_CONTRATO" & ";"
		End Select	
	Next

	If strColumnName = "CONTROL_ID;EXECUTAR;EXECUTADO;TIPO_OPERACAO;TIPO_MOEDA;VALOR_OPERACAO;TIPO_ID_CLIENTE;NRO_ID_CLIENTE;" & _
							"FORMA_PAGAMENTO_ME;FORMA_PAGAMENTO_MN;CNPJ_CORRETORA;MODALIDADE_PAGAMENTO;TIPO_EDICAO_CONTRATO;" Then	
		CheckColumnNames = True
	Else
		CheckColumnNames = False
	End If

End Function