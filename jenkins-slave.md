# Setting up Jenkins Agent

After installing `kubernetes-plugin` for Jenkins
* Go to Manage Jenkins | Bottom of Page | Cloud | Kubernetes (Add kubenretes cloud)
* Fill out plugin values
    * Name: kubernetes
    * Kubernetes URL: https://kubernetes.default:443
    * Kubernetes Namespace: jenkins
    * Credentials | Add | Jenkins (Choose Kubernetes service account option & Global + Save)
    * Test Connection | Should be successful! If not, check RBAC permissions and fix it!
    * Jenkins URL: http://jenkins
    * Tunnel : jenkins:50000
    * Apply cap only on alive pods : yes!
    * Add Kubernetes Pod Template
        * Name: jenkins-slave
        * Namespace: jenkins
        * Labels: jenkins-slave (you will need to use this label on all jobs)
        * Containers | Add Template
            * Name: jnlp
            * Docker Image: jenkins/jnlp-slave
            * Command to run : <Make this blank>
            * Arguments to pass to the command: <Make this blank>
            * Allocate pseudo-TTY: yes
            * Add Volume
                * HostPath type
                * HostPath: /var/run/docker.sock
                * Mount Path: /var/run/docker.sock
        * Timeout in seconds for Jenkins connection: 300
* Save

# Test a build

* Add a Jenkins Pipeline

```
node('jenkins-slave') {
    
     stage('unit-tests') {
        sh(script: """
            docker run --rm alpine /bin/sh -c "echo hello world"
        """)
    }
}
```
