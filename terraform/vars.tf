variable "AWS_REGION" {
    type = string
}

variable "PROJECT_NAME" {
    type = string
}

variable "PROJECT_OWNER" {
    type = string
    description = "Github org running the project"
}

variable "DOMAIN" {
    type = string
}

variable "DEFAULT_ROOT_OBJECT" {
    type = string
    default = "index.html"
}