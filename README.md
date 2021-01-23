# Module/Website

## NOTES:
- You must have a valid route 53 host zone in your AWS account
	- Terraform generated host zones have invalid DNS records that differ from the DNS servers AWS assigns to your site
- You must have AWS cli installed to upload files to S3.
	- Terraform has S3 content resources but they aren't recursive and require manual metadata configuration

TODO: complete me please!
