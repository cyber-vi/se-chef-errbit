# se-task

## how to run locally with dokken:
1. `git clone https://github.com/cyber-vi/se-chef-errbit.git`
2. `cd se-chef-errbit/cookbooks/errbit`
3. `kitchen test`

---
## how to run usind chef/workstation:
```bash 
docker run -it --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/se-chef-errbit:/se-chef-errbit \
  -w /se-chef-errbit/cookbooks/errbit \
  chef/chefworkstation \
  /bin/bash -c "kitchen test"
```

**but in my case I got this error:**
```error
       sh: 0: Can't open /opt/kitchen/run_command
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ActionFailed
>>>>>> Message: 2 actions failed.
>>>>>>     Converge failed on instance <install-app-debian-10>.  Please see .kitchen/logs/install-app-debian-10.log for more details
>>>>>>     Converge failed on instance <install-app-ubuntu-2004>.  Please see .kitchen/logs/install-app-ubuntu-2004.log for more details
>>>>>> ----------------------
>>>>>> Please see .kitchen/logs/kitchen.log for more details
>>>>>> Also try running `kitchen diagnose --all` for configuration
````


---

**source of inspiration:** https://github.com/sergey-zabolotny/errbit-chef