# Flaky

This is a project to simplify collection and analysis of CI results.

- [ ] Be able to upload and see SimpleCov HTML reports.
- [ ] Report Rspec test coverage along the time.
- [ ] Be able to upload and see Sorbet's Spoom HTML reports.
- [ ] Report Sorbet typing along the time.
- [ ] Be able to track failing specs, and analyze which could be flaky in need of some help.

## Development environment

Best way to get started here is to use the "Dev Container".
It should set up all the things you need.
You can find more details about it here https://edgeguides.rubyonrails.org/getting_started_with_devcontainer.html.

After that has been setup, you can run `rails s` on the console it opened.
And access the development app on http://localhost:3000

The Github Oauth app can be be configured here https://github.com/organizations/Superfiliate/settings/applications/2807827

```
curl -X POST http://localhost:3000/api/reports/simplecov \
   -F "bundled_html=@public/examples/zero_coverage.zip" \
   -H "Authorization: Bearer  sffp1_30f66f101d0ac1842481db22768e639c7660d8a66f7df062491f158cb75ad73495f8358372da119cdc425f62116fa10a52fe0b131ad964d7a5c49a826bdfe687"
```

## Production environment

⚠️ WIP, write down details about storage, database, and ENV variables.

### https://flaky.xyz/

It is deployed to fly.io. You can open the app through https://flaky.xyz/ or https://flaky.fly.dev/.

If you have access to Fly you can run `flyctl` commands from you terminal to tweak it.
Or check https://fly.io/apps/flaky.
```bash
flyctl deploy --remote-only
flyctl ssh console
# etc...
```

The Github Oauth app can be be configured here https://github.com/organizations/Superfiliate/settings/applications/2807803

```
your-existing-test-action-on-github:
  permissions:
    pull-requests: write # To post comments on PR

  # ...

  steps:
    # ... Your other test steps, including Rspec/Minitest that generates the SimpleCov HTML report.

    - name: Send SimpleCov to flaky.xyz
      id: flaky-xyz-upload
      if: always()
      run: |
        zip -r simplecov.zip coverage;
        RESPONSE=$(curl -X POST https://flaky.xyz/api/reports/simplecov \
          -F "bundled_html=@simplecov.zip" \
          -H "Authorization: Bearer ${{ secrets.FLAKY_XYZ_TOKEN }}");
        echo "MARKDOWN=$(echo $RESPONSE | jq -r '.markdown')" >> $GITHUB_OUTPUT;

    - name: Comment PR with flaky.xyz results
      uses: thollander/actions-comment-pull-request@v3
      if: always() && github.event_name == 'pull_request'
      with:
        message: |
          ${{ steps.flaky-xyz-upload.outputs.MARKDOWN }}
        comment-tag: flaky-xyx-simplecov
        mode: recreate
```
