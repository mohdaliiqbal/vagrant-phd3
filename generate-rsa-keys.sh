#!/usr/bin/expect -f

set timeout 100

spawn ssh-keygen -t rsa
 
expect {
"Enter file in which to save the key (/root/.ssh/id_rsa):"
{
send -- "/vagrant/tmp/id_rsa\r"
exp_continue
}
"Enter passphrase (empty for no passphrase):"
{
send -- "\r"
exp_continue
}
"Overwrite (y/n)?"
{
send -- "y\r"
exp_continue
}
"Enter same passphrase again:"
{
send -- "\r"
exp_continue
}
eof
{
}
}
