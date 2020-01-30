Let’s say you were tasked with ensuring that EC2 instance volumes have proper tags. Tags are used for many reasons including billing. 
You have 120 instances, which for this example translates to 235 volumes. This could be done manually but that sounds awful and 
impractical. If we take a manual approach we will have to tag more volumes every time an instance is created. Lets examine an 
on machine solution. We are going to look at a bash example. The AWS cli is required for these scripts to work.
