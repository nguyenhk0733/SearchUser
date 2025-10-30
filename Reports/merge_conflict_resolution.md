# Resolving the FavoriteUser model merge conflict

When merging the feature branch that introduces the manual `FavoriteUser` entity definition, keep the block that contains the four attributes (`id`, `login`, `avatarUrl`, `addedAt`) and `codeGenerationType="manual"`. That block is the incoming change if you merge the feature branch into `main`.

Discard the placeholder block that only defines `attribute`, `relationship`, and `fetchedProperty`; that block belonged to the older auto-generated template and will prevent the Core Data layer from compiling.

After accepting the correct block, remove the conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) and save the file before continuing the merge.
