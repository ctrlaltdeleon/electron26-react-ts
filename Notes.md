# My notes

- AI explains that for building distributions, it should be on the native machine or CICD, but don't have that luxury.
- Finding a way to cache all the dependencies into the repo itself so that in the offline build we can reference that instead.
- Ran into the issue for Wine again.
- In Ubuntu VMs, prefer .deb over Snap for development tools like VS Code to avoid sandbox-related issues and keep the environment predictable.'
- Crypto error?
  - Most likely wrong Node/NPM version when it should be 18.20.8, 10.8.2
- Node 16 on the host machine
- Check the file struture if it's strict ac\*\*\*
- Try getting sonarqube to work

# Tasks

- Get the packages working for the boilerplate
  - Make an offline cache so we don't have to reference electron/electron-builder everytime
    - Would make building a lot more easier due to less variables
  - Should still figure out where to put files anyways
  - Wine still breaks, it's weird because I guess building a Win on Linux is dangerous, not recommended, left for the CI/CD to do
- Try BRT Frontend
  - Tried, put down notes on what made the window worked
  - Surprisingly, npm run electron booted up the react code as well?
    - Don't do npm run dev?
- Get backend and mongo working
  - Pin on this, not going anywhere
  - Backend/Mongo already working on dev machines anyway
