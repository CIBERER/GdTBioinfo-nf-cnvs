# Guide for Collaborative GitHub Contribution

This guide outlines the steps and best practices for contributing code collaboratively on GitHub repositories.

0. **Initial Setup (First Time):**
   - Clone the main repository to your local machine using Git. Use the following command:
     ```
     git clone <repository_url>
     ```

1. **Update Local Content (Previously Cloned):**
   - If you have previously cloned the repository, ensure your local content is up to date with the latest changes from the development branch (`devel`) by running:
     ```
     git checkout devel
     git pull origin devel
     ```

   > The development branch, `devel`, serves as the primary workspace for ongoing development and integration of features. Contributors are encouraged to work on their individual branches and merge their changes into the development branch following the outlined guidelines. 
   The `main` branch, on the other hand, functions as the stable, production-ready version of the repository. It will be updated only by the repository maintainer from the development branch once it reaches a mature state. Therefore, it is not intended for regular development work.

2. **Create a New Branch:**
   - Before making any changes, create a new branch for your `issue` (new feature or fix). Use a descriptive name for the branch that reflects the purpose of your changes.
     ```
     git checkout -b <branch_name>
     ```

3. **Make Changes:**
   - Make your code changes or additions in the local repository.

4. **Commit Changes:**
   - Once your changes are complete, stage the files for commit by adding them using:
     ```
     git add <file_name>
     ```
   - Use `git status` to review the changes before committing.
   - Commit the staged changes with a descriptive message using the following command:
     ```
     git commit -m "Brief description of changes"
     ```
   Repeat the above steps (adding files, committing changes) for each logical unit of work within your issue.

5. **Push Changes to the Repository:**
   - Push your committed changes to the repository on GitHub.
     ```
     git push origin <branch_name>
     ```
   Repeat the above steps (committing changes, pushing commits) as many times as necessary until your issue is complete and ready for review.
   
   This approach allows you to break down your work into smaller, manageable units, committing and pushing changes as you progress. Once the entire issue is complete, you can proceed to create a pull request.

6. **Create a Pull Request (PR):**
   - Go to the main repository on GitHub and switch to the branch you just pushed.
   - Click on the "New Pull Request" button.
   - Select the appropriate base repository and branch. Ensure that you select `devel` as the target branch for merging your changes from `<branch_name>`.
   - Use the provided PR template and complete all the sections with relevant information.
   - Review your changes and make sure everything looks good before submitting the PR.

7. **Collaborate and Iterate:**
   - Collaborate with other contributors by addressing feedback, comments, and suggested improvements on your pull request.
   - Make necessary changes in your local repository, commit them, and push them to your branch on GitHub.
   - Engage in discussions within the pull request to ensure clarity and consensus on the proposed changes.

8. **Merge the Pull Request:**
   - Once your pull request is approved and passes any required checks (such as automated tests), it can be merged into the `devel` branch of the repository.
   - Click the "Merge Pull Request" button on GitHub.
   - Suggested: delete your branch after merging for better repository organization and maintenance.
      ```
      git branch -d <branch_name>
      ```

9. **Update Your Local Repository:**
   - After your changes have been merged, it's a good practice to update your local repository with the latest changes from the development branch.
     ```
     git checkout devel
     git pull origin devel
     ```

By following these steps, you can contribute code to the shared GitHub repository in a collaborative and organized manner, ensuring that your contributions are well-received and integrated smoothly.
