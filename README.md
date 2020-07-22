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
          path_to_file: "env/settings/settings.tfvar"
          line_selector: "helm_version"
          dependecy_organization_repo: "helm/helm"
      - name: Create pr if new release
        uses: peter-evans/create-pull-request@<TAG_SHA>
        if: ${{ steps.update_version.outputs.new_version }}
        with:
          commit-message: "helm: upgrade Helm to version ${{ steps.update_version.outputs.newversion }}"
          branch: "upgrade-helm-to-version-${{ steps.update_version.outputs.newversion }}"
          title: "Upgrade Helm to version ${{ steps.update_version.outputs.newversion }}"
          body: "${{ steps.update_version.outputs.release_url }}"
      
```


## Inputs

```yaml
inputs:
  path_to_file:
    description: 'Relative path to file where dependency is specified'
    required: true
  line_selector:
    description: 'A unique string or regex pattern (egrep) of line with version'
    required: true
  dependecy_org_repo:
    description: 'The <org>/<repo> of the dependecy'
    required: true
```

### Example regex pattern for the line selector:

```yaml
line_selector: "helm_version:[ ]+v[0-9]+\.[0-9]+\.[0-9]+"
```


## Outputs

```yaml
outputs:
  new_version:
    description: 'The new version of the dependecy'
  release_url:
    description: 'The url of the release'
```


## Security
When using any action you should always tag the action to a specific commit SHA. The same goes for uplodaded images used by the action. For this and future iterations of the action we will exclusively tag the image by the digest SHA. 


