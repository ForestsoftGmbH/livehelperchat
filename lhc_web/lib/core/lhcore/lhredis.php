<?php

class erLhcoreClassLhRedis
{
    private $redis;

    public function __construct()
    {
		try {
            $params = erConfigClassLhConfig::getInstance()->getSetting( 'redis', 'server');
            $this->redis = new Redis();
	        $this->redis->pconnect($params['host'], $params['port'], 2.5);
			if (isset($params['auth']) && $params['auth'] !== NULL) {
                $this->redis->auth($params['auth']);
            }
	        $this->redis->setOption(Redis::OPT_SERIALIZER, Redis::SERIALIZER_JSON);
			
            //select database by index
            if (isset($params['database'])) {
                $this->redis->select($params['database']);
            }
            
        } catch (Exception $e){
            // Do nothing
        }
    }

    /**
     * ttl = 0, means month store (cache keys versions in most cases), in any other case I use user provided expire key
     * */
    public function set($key, $value, $compress, $ttl = 0)
    {
        $serialized = @serialize($value);
        if ($ttl == 0) {
            $this->redis->setex($key,2678400,$serialized); // One month
        } else {
            $this->redis->setex($key,$ttl,$serialized);
        }
        unset($serialized);
    }
    
    public function get($var)
    {
        $value = $this->redis->get($var);
        return @unserialize($value);
    }
    
    /**
     * Incr does not work then we need to fetch, perhaps just verions issues so i just replace with simple set.
     * */
    public function increment($var,$version)
    {
       $this->redis->set($var,$version);
    }
    
    public function __destruct()
    {
        $this->redis->close();
    }
}
