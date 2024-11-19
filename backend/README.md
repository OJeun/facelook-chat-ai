# ios_project

##### Run the server
yarn dev

##### Build the project
yarn build

##### Start the project
yarn start

##### use this command install new dependencies
yarn add <package_name>

##### use this command to install all dependencies
yarn install

##### use this command to uninstall a dependency
yarn remove <package_name>

## Redis setup

Run redis with docker
docker run -d --name redis -p 6379:6379 redis




### API documentation

##### register a user
route: /api/auth/register
method: POST
body: {
    email: string,
    password: string,
    name: string
}

![alt text](image.png)

##### login
route: /api/auth/login
method: POST
body: {
    email: string,
    password: string
}

![alt text](image-1.png)

#### Routes below requires a authorization header and a valid JWT token!
![alt text](image-3.png)

##### add a friend
route: /api/friend/add
method: POST
body: {
    userId: string,
    friendId: string
}
![alt text](image-2.png)

##### get friends
route: /api/friend/:userId
method: GET
params: userId



