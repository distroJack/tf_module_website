
// Base domain name desired (ex. example.com)
variable "base_domain" {}

// Local path to the static pages you wish to serve on your site
// Default to index.html and error.html as index and error response
variable "static_path" {}

// Logging toggle switch
// True: enables logging in a seperate bucket w/ the name logs.${base_domain}
// False:  disables automatic logging setup
// NOTE: to switch between logging and non-logging, the site MUST be torn down
//       using 'terraform destroy' otherwise aws gets confused and will refuse to 
variable "enable_logging" {
    default = true
}