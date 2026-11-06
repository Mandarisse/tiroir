# TP Tiroir - Git

## 1. Depot + premier commit + GitHub

```bash
git init
git add README.md
git commit -m "Premier commit : ajout du README"
git branch -M main
git remote add origin https://github.com/<utilisateur>/tiroir.git
git push -u origin main
```

On cree le depot, on commit le README, on nomme la branche `main`, on relie le depot GitHub vide (`origin`) puis on pousse. Le `-u` permet ensuite de faire juste `git push`.

## 2. Branche pour le MCD

```bash
git switch -c mcd
git add mcd.png
git commit -m "Ajout du MCD"
git switch main
git merge --no-ff mcd -m "Fusion de la branche mcd"
git branch -d mcd
git push origin --delete mcd   # si la branche avait ete poussee
```

Je cree la branche `mcd`, je commit dessus, je reviens sur `main` et je fusionne avec `--no-ff`, ce qui force un commit de fusion pour garder la trace de la branche dans l'historique. Ensuite je supprime la branche en local puis sur GitHub.

## 3. Conflit dans README.md

```bash
git status
# ouvrir README.md, garder le bon texte, supprimer les <<<<<<< ======= >>>>>>>
git add README.md
git commit
```

`git status` montre les fichiers en conflit. Je corrige le fichier a la main, `git add` pour dire que c'est resolu et `git commit` termine la fusion.

Pour tout annuler :

```bash
git merge --abort
```

Ca remet le depot comme avant la fusion.

## 4. Push refuse

```bash
git pull --rebase origin main
git push origin main
```

`pull --rebase` recupere le travail du coequipier et remet mes commits par-dessus, sans commit de fusion. Si conflit : je corrige, `git add`, `git rebase --continue`. Ensuite le push passe.

## 5. Regrouper 3 commits "wip" deja pousses

```bash
git reset --soft HEAD~3
git commit -m "Message clair"
git push --force-with-lease origin ma-branche
```

`reset --soft HEAD~3` enleve les 3 commits mais garde les modifications, que je recommit en un seul. Comme l'historique a change je dois forcer le push, mais avec `--force-with-lease` : si quelqu'un a pousse entre-temps, git refuse et n'ecrase pas son travail (contrairement a `--force`).

## 6. Corriger le message du dernier commit

```bash
git commit --amend -m "Message corrige"
```

Remplace le dernier commit par le meme avec le bon message. Pas de souci car il n'est pas encore pousse.

## 7. Recuperer un commit apres `git reset --hard HEAD~1`

```bash
git reflog
git reset --hard HEAD@{1}
```

`reflog` garde l'historique de tous les deplacements de HEAD, donc le commit "perdu" y est encore. `reset --hard HEAD@{1}` remet la branche dessus (ou avec le hash lu dans le reflog).

## 8. Bug urgent sur main

```bash
git stash push -u -m "travail en cours"
git switch main
# je corrige le bug, add, commit, push
git switch ma-branche
git stash pop
```

`stash -u` met de cote mon travail (nouveaux fichiers compris). Je corrige le bug sur `main`, je reviens et `stash pop` me rend mon travail.

## 9. Annuler un commit deja pousse

```bash
git switch main
git revert <hash>
git push origin main
```

`revert` cree un nouveau commit qui fait l'inverse. L'historique n'est pas reecrit, donc le push est normal.

## 10. Un seul commit d'une autre branche

```bash
git log --oneline autre-branche
git switch main
git cherry-pick <hash>
```

Je trouve le hash avec `log --oneline`, puis `cherry-pick` applique ce commit seulement sur `main`.
