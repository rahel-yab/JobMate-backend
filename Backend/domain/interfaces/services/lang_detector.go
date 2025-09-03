package interfaces

type IlangDetection interface{
	DetectLanguage(text string)(string)

}