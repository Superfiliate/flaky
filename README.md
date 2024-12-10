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

## Production environment

⚠️ WIP, write down details about storage, database, and ENV variables.

### https://flaky.xyz/

This is deployed to fly.io.
If you have access to the organization you can run `flyctl` commands from you terminal to tweak it.
Or check https://fly.io/apps/flaky.

```bash
flyctl deploy --remote-only
flyctl console
# etc...
```
