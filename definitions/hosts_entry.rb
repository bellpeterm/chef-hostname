define :hosts_entry do
  entry = params[:name]
  if params[:action] == :add
    bash "add #{entry} to /etc/hosts" do
      code    "echo '#{entry}' >> /etc/hosts"
      not_if  "grep '#{entry}'    /etc/hosts"
      notifies :reload, "ohai[reload]"
    end

    ohai "reload" do
      action :nothing
    end
  else
    raise "Operation #{params[:action]} unsupported"
  end
end
