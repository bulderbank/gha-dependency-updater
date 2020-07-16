# Dependency updater - Updates your dependencies automatically with github action

Automatically updates dependecies released to github



## Usage

Via GitHub Workflow

```yml
name: Update Helm if new release
on: 
  schedule:
    - cron:  '0 6 * * *'
jobs:
  check_for_update_job:
    runs-on: ubuntu-latest
    name: Check for updates to Helm
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Automatic update of dependency
        uses: bulderbank/gha-dependency-updater@<TAG_SHA> 
        id: update_version
        with:
          path-to-file: "env/settings/settings.tfvar"
          line-selector: "helm-version"
          dependecy-organization-repo: "helm/helm"
      - name: Create pr if new release
        uses: peter-evans/create-pull-request@<TAG_SHA>
        with:
          commit-message: "helm: upgrade Helm to version ${{ steps.update_version.outputs.new-version }}"
          branch: "upgrade-helm-to-version-${{ steps.update_version.outputs.new-version }}"
          title: "Upgrade Helm to version ${{ steps.update_version.outputs.new-version }}"
          body: "${{ steps.update_version.outputs.release-url }}"
      
```


## Inputs

```yaml
inputs:
  path-to-file:
    description: 'Relative path to file where dependency is specified'
    required: true
  line-selector:
    description: 'A unique string or regex pattern of line with version'
    required: true
  dependecy-organization-repo:
    description: 'The <org>/<repo> of the dependecy'
    required: true
```



## Outputs

```yaml
outputs:
  new-version:
    description: 'The new version of the dependecy'
  release-url:
    description: 'The url of the release'
```


