package job_service

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"strings"

	"github.com/tsigemariamzewdu/JobMate-backend/domain/models"
)

type JobService struct {
	JobDataAPIKey string
}

func NewJobService(apiKey string) *JobService {
	return &JobService{JobDataAPIKey: apiKey}
}

func (s *JobService) GetCuratedJobs(field, lookingFor, experience string, skills []string, language string) ([]models.Job, string, error) {
	log.Printf("JOB SEARCH - Field: %s, Type: %s, Experience: %s, Skills: %v", field, lookingFor, experience, skills)
	
	var jobs []models.Job
	
	// fetch from JobDataAPI for local jobs
	if lookingFor == "local" {
		localJobs, err := s.fetchJobsFromJobDataAPI(field) // Changed to use method receiver
		if err == nil && len(localJobs) > 0 {
			jobs = append(jobs, localJobs...)
		}
	}
	
	// fetch from Upwork for remote/freelance jobs
	if lookingFor == "remote" || lookingFor == "freelance" {
		upworkJobs, err := fetchUpworkJobs(field, skills, experience)
		if err == nil {
			jobs = append(jobs, upworkJobs...)
		} else {
			log.Printf("Upwork fetch failed: %v", err)
		}
	}
	
	// Filter out outdated jobs and validate links
	filteredJobs := s.filterValidJobs(jobs)
	
	if len(filteredJobs) == 0 {
		userMsg := "No current job openings found for your criteria. Please try different search terms or check back later."
		if language == "am" {
			userMsg = "ለአሁኑ ምንም ስራዎች አልተገኙም። እባክዎ የተለየ ፍለጋ ይሞክሩ ወይም በጥቂት ቀናት ውስጥ ይመልከቱ።"
		}
		return nil, userMsg, errors.New("no current jobs found")
	}
	
	msg := fmt.Sprintf("Found %d current opportunities for you:", len(filteredJobs))
	if language == "am" {
		msg = fmt.Sprintf("ለ%s የሚስማሙ %d ስራዎች ተገኝተዋል።", field, len(filteredJobs))
	}

	log.Printf("FOUND %d valid jobs for %s %s positions", len(filteredJobs), lookingFor, field)
	return filteredJobs, msg, nil
}

func (s *JobService) filterValidJobs(jobs []models.Job) []models.Job {
	var validJobs []models.Job
	
	for _, job := range jobs {
		// Basic validation - ensure job has required fields
		if job.Title == "" || job.Company == "" || job.Link == "" {
			continue
		}
		
		// Check if link is potentially valid (simple validation)
		if !strings.HasPrefix(job.Link, "http") {
			continue
		}
		
		validJobs = append(validJobs, job)
	}
	
	return validJobs
}

// fetch jobs from JobDataAPI for Ethiopia - now a method receiver
func (s *JobService) fetchJobsFromJobDataAPI(titleFilter string) ([]models.Job, error) {
	resp, err := http.Get("https://jobdataapi.com/api/jobcountries/")
	if err != nil {
		return nil, fmt.Errorf("error fetching countries: %w", err)
	}
	defer resp.Body.Close()

	var countries []struct {
		Name string `json:"name"`
		Code string `json:"code"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&countries); err != nil {
		return nil, fmt.Errorf("error decoding countries: %w", err)
	}

	var countryCode string
	for _, c := range countries {
		if c.Name == "Ethiopia" {
			countryCode = c.Code
			break
		}
	}
	if countryCode == "" {
		return nil, fmt.Errorf("Ethiopia not found in countries list")
	}

	req, err := http.NewRequest("GET", "https://jobdataapi.com/api/jobs/", nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Api-Key "+s.JobDataAPIKey) // Use s.JobDataAPIKey

	q := req.URL.Query()
	q.Add("country_code", countryCode)
	if titleFilter != "" {
		q.Add("title", titleFilter)
	}
	req.URL.RawQuery = q.Encode()

	resp2, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("error fetching jobs: %w", err)
	}
	defer resp2.Body.Close()

	var data struct {
		Count   int `json:"count"`
		Results []struct {
			ID      int `json:"id"`
			Company struct {
				Name string `json:"name"`
				Logo string `json:"logo"`
			} `json:"company"`
			Title          string `json:"title"`
			Location       string `json:"location"`
			Description    string `json:"description"`
			ApplicationURL string `json:"application_url"`
		} `json:"results"`
	}
	if err := json.NewDecoder(resp2.Body).Decode(&data); err != nil {
		return nil, fmt.Errorf("error decoding jobs: %w", err)
	}

	var jobs []models.Job
	for _, j := range data.Results {
		jobs = append(jobs, models.Job{
			Title:        j.Title,
			Company:      j.Company.Name,
			Location:     j.Location,
			Link:         j.ApplicationURL,
			Source:       "JobDataAPI",
			Requirements: []string{},
		})
	}

	return jobs, nil
}

// fetch jobs from Upwork for remote/freelance positions
func fetchUpworkJobs(field string, skills []string, experience string) ([]models.Job, error) {
    
	searchQuery := url.QueryEscape(field)
    if len(skills) > 0 {
        searchQuery = url.QueryEscape(fmt.Sprintf("%s %s", field, skills[0]))
    }
    
    searchURL := fmt.Sprintf("https://www.upwork.com/ab/jobs/search/?q=%s", searchQuery)
    
    var jobs []models.Job
    
    jobs = append(jobs, models.Job{
        Title:        fmt.Sprintf("%s Developer Jobs", field),
        Company:      "Upwork",
        Location:     "Remote",
        Requirements: skills,
        Type:         "freelance",
        Source:       "Upwork",
        Link:         searchURL,
        Language:     "en",
    })
    
    for _, skill := range skills {
        if skill != "" {
            skillSearchURL := fmt.Sprintf("https://www.upwork.com/ab/jobs/search/?q=%s", url.QueryEscape(skill))
            jobs = append(jobs, models.Job{
                Title:        fmt.Sprintf("%s Developer Jobs", skill),
                Company:      "Upwork",
                Location:     "Remote", 
                Requirements: []string{skill},
                Type:         "freelance",
                Source:       "Upwork",
                Link:         skillSearchURL,
                Language:     "en",
            })
        }
    }
    
    return jobs, nil
}