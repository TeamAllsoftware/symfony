# Image Symfony 6 Docker

## Tester
### Test modification Dockerfile
Pour tester ajouts/modifs du Dockerfile :
- `docker build . --no-cache`

### Renter le conteneur
Pour vérifier que tout est OK dans le conteneur, on peut le lancer :
- `docker build -t symfony-docker-test . --no-cache`
- `docker container run -d --name symfony-docker-test-run symfony-docker-test`
- `docker container exec -it symfony-docker-test-run bash`

Faire les contrôles souhaités en bash sur le conteneur
Sortir du conteneur puis arrêter/supprimer le conteneur :
- `docker rm symfony-docker-test-run --force`

## Publication DockerHub
Voir le dernier nom/version de l'image sur DockerHub.
Incrementer la version (-vX) en fonction: `allsoftware/symfony:6-php-8.2-vX`

### Publier
Pour publier l'image :
- `docker login`
- `docker build -t [IMAGE:nouveau_tag] .`
- `docker push [IMAGE:nouveau_tag]`

Voir plus sur : `O:\Documentation\DockerHub\Création d'image dockerhub.txt`
