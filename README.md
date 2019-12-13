# Chat App - Rapport

Mohamed NIZAMUDDIN
Skander SERSI

Le but du projet est de faire le front d'une application de chat instantanné en elm.

Nous avons décidé dans notre modele de stocker la liste des Utilisateurs connectés (User), la liste des messages reçus (ReceivedMessage), un message de type String correspondant au message que l'on envoi a tout le monde, un username de type String qui correspond a notre pseudo dans le chat et un booleen connected qui permet de savoir si on est connecté ou pas.

Dans notre modele on differencie déjà deux type messages reçus soit des messages, soit des notification.

Nous avons plusieurs type de Commande que l'on envoi/recoit en fonction des interactions de que l'on a avec notre chat:
- Connect User quand on a entré un username et que l'on clique sur connect
- ConnectPrivate quand on a decide de se connecter de maniere anonyme
- UserInput String qui met a jour notre username avant la connexion
- MessageInput String qui met a jour la chaine de caractère correspondant à notre message avant l'envoi
- SendMessage Message correspondant a l'envoi d'un message a tout les utilisateurs connectés
- SendSuccess correspondant a la confirmation de l'envoi de notre message
- GotUsers quand on recupere la liste des utilisateurs connectés

Globalement on effectue Deux requetes post dans notre chat:
-Une requete pour l'envoi de message
-Une requete pour recuper les utilisateurs connectés

Nous avons des encodeurs et des decodeurs de messages pour l'envoi de message ou decoder les messages reçus.

Pour la vue nous avons utilisés elm-bootstrap et du css.

## Fonctionnalités
Nous avons réalisés tout les objectifs obligatoires
- Se connecter sur l'applicaiton avec un username
- Pouvoir envoyer des messages et voir les message des autres sous le format s uivant : "[username]:content"
- Recevoir une notification quand quelqu'un se connecte

Nous avons également rajoutez quelques fonctionnalités suplementaires comme:
- Se connectez en anonyme
- Un format different quand on reçoit un message privés
- Ne pas prendre en compte le message si c'est un message vide
- Voir la liste des utilisateurs connectés.

## Utilisation
```bash
yarn start
 ```