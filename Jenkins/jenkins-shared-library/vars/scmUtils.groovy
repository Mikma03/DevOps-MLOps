def gitCheckout(Map args) {
    checkout([
        $class: 'GitSCM',
        branches: [[name: args.revision]],
        userRemoteConfigs: [[url: args.url, credentialsId: args.credentialsId]]
    ])
}

def setGitUserInfo(Map args) {
    withCredentials([usernamePassword(credentialsId: args.credentialsId, passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
        sh "git config --global user.name '${args.username}'"
        sh "git config --global user.email '${args.email}'"
    }
}

def gitCommit(Map args, String path) {
    sh "git add ${path}"
    sh "git commit -m '${args.commitMessage}'"
}

def gitPush(String credentialsId, String gitHubPath) {
    withCredentials([usernamePassword(credentialsId: credentialsId, passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
        sh "git remote add origin ${gitHubPath}"
        sh 'git push --set-upstream origin $(git symbolic-ref --short HEAD)'
    }
}
