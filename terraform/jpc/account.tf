variable "account" {
    description = "Account Username"
    default = ""
}

variable "key_path" {
    description = "Path to rsa key installed in joyent account"
    default = "~/.ssh/id_rsa"
}

variable "key_id" {
    description = "Signature of the above rsa key"
    default = ""
}
