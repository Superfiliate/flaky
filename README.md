# Flaky

This is a project to simplify collection and analysis of CI results.

- [x] Be able to upload and see SimpleCov HTML reports.
- [ ] Update instructions with the working version from the monorepo.
- [ ] Report Rspec test coverage along the time, per-branch.
- [ ] Be able to upload and see Sorbet's Spoom HTML reports.
- [ ] Report Sorbet typing along the time.
- [ ] Be able to track failing specs, and analyze which could be flaky in need of some extra attention.

## Development environment

Best way to get started here is to use the "Dev Container".
It should set up all the things you need.
You can find more details about it here https://edgeguides.rubyonrails.org/getting_started_with_devcontainer.html.

After that has been setup, you can run `rails s` on the console it opened.
And access the development app on http://localhost:3000

The Github Oauth app can be be configured here https://github.com/organizations/Superfiliate/settings/applications/2807827

```
bin/rails test test/**;
rsync -av --include='*/' --include='*.rb' --exclude='*' . coverage/code;
zip -r simplecov.zip coverage;
curl -X POST http://localhost:3000/api/reports/simplecov \
  -F "part=@simplecov.zip" \
  -F "expected_parts=2" \
  -F "run_identifier=a3s4d5f6g7h8xtcyujk" \
  -H "Authorization: Bearer sffp1_9824289e0db0ccd1619696a876d4331211173501f6b70adcf2a8d3380224582a9bef654a18775418c6ac58a0d7fcca51a620f92a6c019d993aa0bc7dc636d975"
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
          -F "part=@simplecov.zip" \
          -F "expected_parts=1" \
          -F "run_identifier=${{ github.run_id }}" \
          -F "branch=${{ github.head_ref || github.ref_name }}" \
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
