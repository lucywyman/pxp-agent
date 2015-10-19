step 'Copy test certs to agents'
agents.each do |agent|
  rsync_to(agent, '../test-resources', '~/test-resources')
end

step 'Create config file'
agents.each do |agent|
  if (agent.platform.upcase.start_with?('WINDOWS'))
    on agent, 'mkdir /cygdrive/c/ProgramData/PuppetLabs/pxp-agent'
    on agent, 'mkdir /cygdrive/c/ProgramData/PuppetLabs/pxp-agent/etc'
    config = <<OUTPUT
{
  "broker-ws-uri" : "wss://#{master}:8142/pcp/",
  "ssl-key" : "C:\\\\cygwin64\\\\home\\\\Administrator\\\\test-resources\\\\ssl\\\\private_keys\\\\client01.example.com.pem",
  "ssl-ca-cert" : "C:\\\\cygwin64\\\\home\\\\Administrator\\\\test-resources\\\\ssl\\\\ca\\\\ca_crt.pem",
  "ssl-cert" : "C:\\\\cygwin64\\\\home\\\\Administrator\\\\test-resources\\\\ssl\\\\certs\\\\client01.example.com.pem"
}
OUTPUT
    create_remote_file(agent, '/cygdrive/c/ProgramData/PuppetLabs/pxp-agent/etc/pxp-agent.conf', config)
    #TODO - RE-5776 - shouldn't need to create folders manually
    on agent, 'mkdir /cygdrive/c/ProgramData/PuppetLabs/pxp-agent/var'
    on agent, 'mkdir /cygdrive/c/ProgramData/PuppetLabs/pxp-agent/var/log'
    on agent, 'mkdir /cygdrive/c/ProgramData/PuppetLabs/pxp-agent/var/spool'
  else
    config = <<OUTPUT
{
  "broker-ws-uri" : "wss://#{master}:8142/pcp/",
  "ssl-key" : "/root/test-resources/ssl/private_keys/client01.example.com.pem",
  "ssl-ca-cert" : "/root/test-resources/ssl/ca/ca_crt.pem",
  "ssl-cert" : "/root/test-resources/ssl/certs/client01.example.com.pem"
}
OUTPUT
    create_remote_file(agent, '/etc/puppetlabs/pxp-agent/pxp-agent.conf', config)
  end
end
