variable "AWS_REGION" {
    type = string
}

variable "PROJECT_NAME" {
    type = string
}

variable "PROJECT_OWNER" {
    type = string
    description = ""
}

variable "DOMAIN" {
    type = string
}

variable "DEFAULT_ROOT_OBJET" {
    type = string
    default = "index.html"
}