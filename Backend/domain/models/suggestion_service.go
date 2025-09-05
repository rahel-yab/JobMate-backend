package models

type Suggestion struct {
	Courses        []CourseSuggestion
	GeneralAdvice  []string
}


type CourseSuggestion struct {
	Title       string
	Provider    string
	URL         string
	Description string
	Skill       string
}
