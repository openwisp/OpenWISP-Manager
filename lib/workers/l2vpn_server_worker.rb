class L2vpnServerWorker < BackgrounDRb::MetaWorker
  set_worker_name :l2vpn_server_worker
  
  def create(args = nil)
    cache['dh'] = nil
    cache['tls'] = nil
  end
  
  def genDh
    cache['dh'] = Ca.create_DH.to_s
  end
  
  def genTls
    cache['tls'] = Ca.create_tls_auth
  end
  
  def clean
    cache['dh'] = nil
    cache['tls'] = nil
  end
  
  def getDh
    start = Time.now()
    while (cache['dh'].nil?) do
      break if Time.now() - start > 1.minute
    end
    return cache['dh']       
  end
  
  def getTls
    start = Time.now()
    while  (cache['tls'].nil?)  do
      break if Time.now() - start > 1.minute
    end
    return cache['tls']
  end
  
end

