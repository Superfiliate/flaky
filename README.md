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
   -F "bundled_html=@/Users/evsasse/code/coverage.zip" \
   -H "Authorization: Bearer  sffp1_745c663a6d34b1bddf760ff823e4591d6f370633828274921b4f36a1e55820f4275e04429c64de99408c106f660b50d010305b6366fded8d89ccd8669d038a20"
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
