# Degree milestones

**Language:** English | [简体中文](README.zh-CN.md)

Create one directory per durable review or submission event, for example:

```text
milestones/
└── defense_2027/
    ├── milestone.yml
    ├── feedback/          # received files; never edited in place
    ├── response/          # point ledger and dispositions
    ├── materials/         # defense or review deliverables
    └── RECORD_2027-05-20.md
```

Suggested `kind` values are `proposal`, `annual-review`, `pre-defense`, `defense`, `corrections`, and `deposit`. Dates, rules, and outcomes are user-confirmed facts.
