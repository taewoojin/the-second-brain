---
title: MCP를 통해 Claude Code를 도구에 연결하기
source: https://code.claude.com/docs/ko/mcp
author:
published:
created: 2026-04-14
description: Model Context Protocol을 사용하여 Claude Code를 도구에 연결하는 방법을 알아봅니다.
tags:
  - clippings
---
Claude Code는 AI 도구 통합을 위한 오픈 소스 표준인 [Model Context Protocol (MCP)](https://modelcontextprotocol.io/introduction) 를 통해 수백 개의 외부 도구 및 데이터 소스에 연결할 수 있습니다. MCP 서버는 Claude Code에 도구, 데이터베이스 및 API에 대한 액세스를 제공합니다.

## MCP로 할 수 있는 것

MCP 서버가 연결되면 Claude Code에 다음을 요청할 수 있습니다:
- **이슈 추적기에서 기능 구현**: “JIRA 이슈 ENG-4521에 설명된 기능을 추가하고 GitHub에서 PR을 생성하세요.”
- **모니터링 데이터 분석**: “Sentry와 Statsig을 확인하여 ENG-4521에 설명된 기능의 사용량을 확인하세요.”
- **데이터베이스 쿼리**: “PostgreSQL 데이터베이스를 기반으로 기능 ENG-4521을 사용한 무작위 사용자 10명의 이메일을 찾으세요.”
- **디자인 통합**: “Slack에 게시된 새로운 Figma 디자인을 기반으로 표준 이메일 템플릿을 업데이트하세요.”
- **워크플로우 자동화**: “이 10명의 사용자를 새로운 기능에 대한 피드백 세션에 초대하는 Gmail 초안을 생성하세요.”
- **외부 이벤트에 반응**: MCP 서버는 [채널](https://code.claude.com/docs/ko/channels) 로도 작동할 수 있으며, 세션에 메시지를 푸시하므로 Claude는 자리를 비운 동안 Telegram 메시지, Discord 채팅 또는 webhook 이벤트에 반응할 수 있습니다.

## 인기 있는 MCP 서버

Claude Code에 연결할 수 있는 일반적으로 사용되는 MCP 서버는 다음과 같습니다:

타사 MCP 서버를 사용할 때는 자신의 책임하에 사용하십시오 - Anthropic은 이러한 모든 서버의 정확성이나 보안을 검증하지 않았습니다. 설치하는 MCP 서버를 신뢰하는지 확인하세요. 신뢰할 수 없는 콘텐츠를 가져올 수 있는 MCP 서버를 사용할 때는 특히 주의하세요. 이러한 서버는 프롬프트 주입 위험에 노출될 수 있습니다.

[**Ticket Tailor**](https://help.tickettailor.com/en/articles/11892797-how-to-connect-ticket-tailor-to-your-favourite-ai-agent)

Event platform for managing tickets, orders & more

Command

`claude mcp add --transport http tickettailor https://mcp.tickettailor.ai/mcp`

[**Linear**](https://linear.app/docs/mcp)

Manage issues, projects & team workflows in Linear

Command

`claude mcp add --transport http linear https://mcp.linear.app/mcp`

[**Hugging Face**](https://huggingface.co/settings/mcp)

Access the Hugging Face Hub and thousands of Gradio Apps

Command

`claude mcp add --transport http hugging-face https://huggingface.co/mcp`

[**Amplitude**](https://amplitude.com/docs/analytics/amplitude-mcp)

Search, access, and get insights on your Amplitude data

Command

`claude mcp add --transport http amplitude https://mcp.amplitude.com/mcp`

[**Atlassian Rovo**](https://community.atlassian.com/forums/Atlassian-Platform-articles/Using-the-Atlassian-Remote-MCP-Server-beta/ba-p/3005104)

Access Jira & Confluence from Claude

Command

`claude mcp add --transport http atlassian https://mcp.atlassian.com/v1/mcp`

[**Blockscout**](https://github.com/blockscout/mcp-server)

Access and analyze blockchain data

Command

`claude mcp add blockscout --transport http https://mcp.blockscout.com/mcp`

[**Cloudflare Developer Platform**](https://www.support.cloudflare.com/)

Build applications with compute, storage, and AI

Command

`claude mcp add --transport http cloudflare https://bindings.mcp.cloudflare.com/mcp`

[**Egnyte**](https://developers.egnyte.com/docs/Remote_MCP_Server)

Securely access and analyze Egnyte content

Command

`claude mcp add --transport http egnyte https://mcp-server.egnyte.com/mcp`

[**Figma**](https://help.figma.com/hc/en-us/articles/32132100833559)

Generate diagrams and better code from Figma context

Command

`claude mcp add --transport http figma-remote-mcp https://mcp.figma.com/mcp`

[**Guru**](https://help.getguru.com/docs/connecting-gurus-mcp-server)

Search and interact with your company knowledge

Command

`claude mcp add guru --transport http https://mcp.api.getguru.com/mcp`

[**Jotform**](https://www.jotform.com/developers/mcp/)

Create forms & analyze submissions inside Claude

Command

`claude mcp add --transport http jotform https://mcp.jotform.com/mcp-app`

[**monday.com**](https://developer.monday.com/apps/docs/mondaycom-mcp-integration)

Manage projects, boards, and workflows in monday.com

Command

`claude mcp add --transport http monday https://mcp.monday.com/mcp`

[**Notion**](https://developers.notion.com/docs/mcp)

Connect your Notion workspace to search, update, and power workflows across tools

Command

`claude mcp add --transport http notion https://mcp.notion.com/mcp`

[**PayPal**](https://mcp.paypal.com/)

Access PayPal payments platform

Command

`claude mcp add --transport http paypal https://mcp.paypal.com/mcp`

[**Stripe**](https://docs.stripe.com/mcp)

Payment processing and financial infrastructure tools

Command

`claude mcp add --transport http stripe https://mcp.stripe.com `

[**Supabase**](https://supabase.com/docs/guides/getting-started/mcp)

Manage databases, authentication, and storage

Command

`claude mcp add --transport http supabase https://mcp.supabase.com/mcp `

[**Vercel**](https://vercel.com/docs/mcp/vercel-mcp)

Analyze, debug, and manage projects and deployments

Command

` claude mcp add --transport http vercel https://mcp.vercel.com`

[**Wix**](https://dev.wix.com/docs/sdk/articles/use-the-wix-mcp/about-the-wix-mcp)

Manage and build sites and apps on Wix

Command

`claude mcp add wix --transport http https://mcp.wix.com/mcp`

[**Coupler.io**](https://help.coupler.io/article/592-coupler-local-mcp-server)

Access business data from hundreds of sources

Command

`claude mcp add --transport http coupler https://mcp.coupler.io/mcp`

[**Dice**](https://www.dice.com/about/mcp)

Find active tech jobs on Dice

Command

`claude mcp add dice --transport http https://mcp.dice.com/mcp`

[**Airtable**](https://github.com/domdomegg/airtable-mcp-server)

Read and write Airtable databases

[**Miro**](https://developers.miro.com/docs/miro-mcp)

Access and create new content on Miro boards

Command

`claude mcp add --transport http miro https://mcp.miro.com/ `

[**Port IO**](https://docs.port.io/ai-interfaces/port-mcp-server/overview-and-installation)

Search your context lake and safely run actionsRequires user-specific URL. [Get your URL here](https://docs.port.io/ai-interfaces/port-mcp-server/overview-and-installation/?mcp-setup=claude&region=eu#installing-port-mcp).

[**Aiwyn Tax (formerly Column Tax)**](https://docs.columntax.com/page/aiwyn-tax-mcp-server)

Estimate your federal & state taxes with Aiwyn's tax engine

Command

`claude mcp add --transport http aiwyn-tax https://mcp.columnapi.com/mcp `

[**Circleback**](https://circleback.ai/docs/mcp)

Search and access context from meetings

Command

`claude mcp add circleback --transport http https://app.circleback.ai/api/mcp`

[**Clarify**](https://docs.clarify.ai/en/articles/13367278-clarify-mcp)

Query your CRM. Create records. Ask anything.

Command

`claude mcp add --transport http clarify https://api.clarify.ai/mcp `

[**Clarity AI**](https://clarity-sfdr20-mcp.pro.clarity.ai/)

Simulate fund classifications under proposed SFDR 2.0

Command

`claude mcp add --transport http clarity-ai https://clarity-sfdr20-mcp.pro.clarity.ai/mcp `

[**Day AI**](https://day.ai/mcp)

Know everything about your prospects & customers with CRMx

Command

`claude mcp add day-ai --transport http https://day.ai/api/mcp`

[**bioRxiv**](https://claude.com/resources/tutorials/using-the-biorxiv-and-medrxiv-connector-in-claude)

Access bioRxiv and medRxiv preprint data

Command

`claude mcp add biorxiv --transport http https://hcls.mcp.claude.com/biorxiv/mcp`

[**ChEMBL**](https://claude.com/resources/tutorials/using-the-chembl-connector-in-claude)

Access the ChEMBL Database

Command

`claude mcp add chembl --transport http https://hcls.mcp.claude.com/chembl/mcp`

[**Clinical Trials**](https://claude.com/resources/tutorials/using-the-clinicaltrials-gov-connector-in-claude)

Access ClinicalTrials.gov data

Command

`claude mcp add clinical-trials --transport http https://hcls.mcp.claude.com/clinical_trials/mcp`

[**CMS Coverage**](https://claude.com/resources/tutorials/using-the-cms-coverage-connector-in-claude)

Access the CMS Coverage Database

Command

`claude mcp add cms-coverage --transport http https://hcls.mcp.claude.com/cms_coverage/mcp`

[**ICD-10 Codes**](https://claude.com/resources/tutorials/using-the-icd-10-connector-in-claude)

Access ICD-10-CM and ICD-10-PCS code sets

Command

`claude mcp add icd-10-codes --transport http https://hcls.mcp.claude.com/icd10_codes/mcp`

[**NPI Registry**](https://claude.com/resources/tutorials/using-the-npi-registry-connector-in-claude)

Access US National Provider Identifier (NPI) Registry

Command

`claude mcp add npi-registry --transport http https://hcls.mcp.claude.com/npi_registry/mcp`

[**DevRev**](https://support.devrev.ai/en-US/devrev/article/ART-21859-remote-mcp-server)

Search and update your company's knowledge graph

Command

`claude mcp add devrev --transport http https://api.devrev.ai/mcp/v1`

[**Exa**](https://docs.exa.ai/reference/exa-mcp)

Web Search + Code Docs Search

Command

`claude mcp add --transport http exa https://mcp.exa.ai/mcp `

[**Fiscal.ai**](https://docs.fiscal.ai/docs/guides/mcp-integration)

Clean Public Equity Fundamental Data

Command

`claude mcp add --transport sse fiscal-ai https://api.fiscal.ai/mcp/sse `

[**Granola**](https://help.granola.ai/article/granola-mcp#set-up-guide)

The AI notepad for meetings

Command

`claude mcp add --transport http granola https://mcp.granola.ai/mcp `

[**Harmonic**](https://support.harmonic.ai/en/articles/12785899-harmonic-mcp-server-getting-started-guide)

Discover, research, and enrich companies and people

Command

`claude mcp add harmonic --transport http https://mcp.api.harmonic.ai`

[**Krisp**](https://help.krisp.ai/hc/en-us/articles/25416265429660-Krisp-MCP-Supported-tools)

Add your meetings context via transcripts and notes

Command

`claude mcp add --transport http krisp https://mcp.krisp.ai/mcp `

[**Lorikeet**](https://docs.lorikeetcx.ai/mcp/mcp-server)

A universal concierge for complex businesses

Command

`claude mcp add --transport http lorikeet https://api.lorikeetcx.ai/v1/mcp `

[**LunarCrush**](https://lunarcrush.com/developers/api/ai)

Add real-time social media data to your searches

Command

`claude mcp add lunarcrush --transport http https://lunarcrush.ai/mcp`

[**Mem**](https://docs.mem.ai/mcp/overview)

The AI notebook for everything on your mind

Command

`claude mcp add --transport http mem https://mcp.mem.ai/mcp `

[**Metaview**](https://support.metaview.ai/integrations/mcp-integration/mcp-overview.mdx)

The AI platform for recruiting.

Command

`claude mcp add --transport http metaview https://mcp.metaview.ai/mcp `

[**Midpage Legal Research**](https://midpage-docs.apidocumentation.com/documentation/integration/mcp-tools)

Conduct legal research and create work product

Command

`claude mcp add --transport http midpage https://app.midpage.ai/mcp `

[**Scholar Gateway**](https://docs.scholargateway.ai/)

Enhance responses with scholarly research and citations

Command

`claude mcp add scholar-gateway --transport http https://connector.scholargateway.ai/mcp`

[**Sprouts Data Intelligence**](https://support.sprouts.ai/en/articles/13384582-sprouts-mcp-server-documentation#h_541c149a52)

From query to qualified lead in seconds.

Command

`claude mcp add --transport http sprouts https://sprouts-mcp-server.kartikay-dhar.workers.dev `

[**Gainsight (Staircase AI)**](https://support.gainsight.com/Staircase_AI/Staircase_AI_Features/Connect_Staircase_AI_to_LLMs_Using_MCP#Install_Staircase_AI_MCP_for_Claude)

Power AI Workflows with Customer Context

Command

`claude mcp add --transport http gainsight-staircase-ai https://mcp.staircase.ai/mcp `

[**Sybill**](https://api.sybill.ai/docs/mcp.html)

Ask AI about your sales calls, deals & pipeline

Command

`claude mcp add sybill --transport http https://mcp.sybill.ai/mcp`

[**Vibe Prospecting**](https://developers.explorium.ai/mcp-docs/agentsource-mcp)

Find company & contact data

Command

`claude mcp add vibe-prospecting --transport http https://vibeprospecting.explorium.ai/mcp`

[**Windsor.ai**](https://windsor.ai/introducing-windsor-mcp/#method-1-using-claude-desktop-3)

Connect 325+ marketing, analytics and CRM data sources

Command

`claude mcp add windsor-ai --transport http https://mcp.windsor.ai`

[**Gamma**](https://gamma.app/docs/Gamma-MCP-Server-Documentation-m6p43kobgzy15zj?mode=doc)

Create presentations, docs, socials, and sites with AI

Command

`claude mcp add gamma --transport http https://mcp.gamma.app/mcp`

[**Lucid**](https://help.lucid.co/hc/en-us/articles/42578801807508-Integrate-Lucid-with-AI-tools-using-the-Lucid-MCP-server)

Ideate, diagram, and align teams

Command

`claude mcp add --transport http lucid https://mcp.lucid.app/mcp `

[**Netlify**](https://docs.netlify.com/build/build-with-ai/netlify-mcp-server/)

Create, deploy, manage, and secure websites on Netlify.

Command

`claude mcp add --transport http netlify https://netlify-mcp.netlify.app/mcp`

[**AWS Marketplace**](https://docs.aws.amazon.com/marketplace/latest/APIReference/marketplace-mcp-server.html)

Discover, evaluate, and buy solutions for the cloud

Command

`claude mcp add aws-marketplace --transport http https://marketplace-mcp.us-east-1.api.aws/mcp`

[**Kindora Funder Discovery**](https://kindora.co/mcp)

Find funders who support causes like yours

Command

`claude mcp add --transport http kindora-funder-discovery https://kindora-mcp.azurewebsites.net/mcp/ `

[**Omni Analytics**](https://docs.omni.co/ai/mcp)

Query your data using natural language through Omni's semantic model

Command

`claude mcp add --transport http omni-analytics https://callbacks.omniapp.co/callback/mcp `

[**ActiveCampaign**](https://developers.activecampaign.com/page/mcp)

Autonomous marketing to transform how you workRequires user-specific URL. [Get your URL here](https://developers.activecampaign.com/page/mcp).

[**Ahrefs**](https://docs.ahrefs.com/docs/mcp/reference/introduction)

SEO & AI search analytics

Command

`claude mcp add ahrefs --transport http https://api.ahrefs.com/mcp/mcp`

[**AirOps**](https://docs.airops.com/mcp)

Craft content that wins AI search

Command

`claude mcp add airops --transport http https://app.airops.com/mcp`

[**Airwallex Developer**](https://www.airwallex.com/docs/developer-tools/ai/developer-mcp)

Integrate with the Airwallex Platform using Claude

Command

`claude mcp add --transport http airwallex-developer https://mcp-demo.airwallex.com/developer `

[**Asana**](https://developers.asana.com/docs/mcp-server)

Connect to Asana to coordinate tasks, projects, and goals

Command

`claude mcp add --transport http asana https://mcp.asana.com/v2/mcp`

[**Attio**](https://docs.attio.com/mcp/overview)

Search, manage, and update your Attio CRM from Claude

Command

`claude mcp add --transport http attio https://mcp.attio.com/mcp `

[**Aura**](https://docs.getaura.ai/)

Company intelligence & workforce analytics

Command

`claude mcp add --transport http auraintelligence https://mcp.auraintelligence.com/mcp`

[**Benchling**](https://help.benchling.com/hc/en-us/articles/40342713479437-Benchling-MCP)

Connect to R&D data, source experiments, and notebooksRequires user-specific URL. [Get your URL here](https://help.benchling.com/hc/en-us/articles/40342713479437-Benchling-MCP).

[**BioRender**](https://help.biorender.com/hc/en-gb/articles/30870978672157-How-to-use-the-BioRender-MCP-connector)

Search for and use scientific templates and icons

Command

`claude mcp add biorender --transport http https://mcp.services.biorender.com/mcp`

[**Bitly**](https://dev.bitly.com/bitly-mcp/)

Shorten links, generate QR Codes, and track performance

Command

`claude mcp add bitly --transport http https://api-ssl.bitly.com/v4/mcp`

[**MT Newswires**](https://console.blueskyapi.com/docs/EDGE/news/MT_NEWSWIRES_Global#mcp)

Trusted real-time global financial news provider

Command

`claude mcp add --transport http mtnewswire `

[**Box**](https://developer.box.com/guides/box-mcp)

Search, access and get insights on your Box content

Command

`claude mcp add box --transport http https://mcp.box.com`

[**Canva**](https://www.canva.dev/docs/connect/canva-mcp-server-setup/)

Search, create, autofill, and export Canva designs

Command

`claude mcp add --transport http canva https://mcp.canva.com/mcp`

[**CB Insights**](https://mcp.cbinsights.com/)

Predictive intelligence on private companies

Command

`claude mcp add --transport http cb-insights https://mcp.cbinsights.com `

[**CData Connect AI**](https://cloud.cdata.com/docs/Claude-Client.html)

Managed MCP platform for 350 sources

Command

`claude mcp add cdata-connect-ai --transport http https://mcp.cloud.cdata.com/mcp`

[**PubMed**](https://support.claude.com/en/)

Search biomedical literature from PubMed

Command

`claude mcp add pubmed --transport http https://pubmed.mcp.claude.com/mcp`

[**Clay**](https://www.notion.so/clayrun/Clay-Claude-MCP-Server-Documentation-2ef7e66eb01480c9820de48041591aeb?showMoveTo=true&saveParent=true)

Find prospects. Research accounts. Personalize outreach

Command

`claude mcp add --transport http clay https://api.clay.com/v3/mcp `

[**Clerk**](https://clerk.com/docs/guides/ai/mcp/clerk-mcp-server)

Add authentication, organizations, and billing

Command

`claude mcp add --transport http clerk https://mcp.clerk.com/mcp `

[**ClickUp**](https://help.clickup.com/hc/en-us/articles/33335772678423-What-is-ClickUp-MCP)

Project management & collaboration for teams & agents

Command

`claude mcp add clickup --transport http https://mcp.clickup.com/mcp`

[**Cloudinary**](https://cloudinary.com/documentation/cloudinary_llm_mcp#available_mcp_servers)

Manage, transform and deliver your images & videos

Command

`claude mcp add --transport http cloudinary https://asset-management.mcp.cloudinary.com/sse`

[**Consensus**](https://docs.consensus.app/docs/mcp)

Explore scientific research

Command

`claude mcp add --transport http consensus https://mcp.consensus.app/mcp `

[**Context7**](https://context7.com/docs/overview)

Up-to-date docs for LLMs and AI code editors

Command

`claude mcp add --transport http context7 https://mcp.context7.com/mcp `

[**Crossbeam**](https://help.crossbeam.com/en/articles/12601327-crossbeam-mcp-server-beta)

Explore partner data and ecosystem insights in Claude

Command

`claude mcp add crossbeam --transport http https://mcp.crossbeam.com`

Real time prices, orders, charts, and more for crypto

Command

`claude mcp add --transport http crypto.com https://mcp.crypto.com/market-data/mcp`

[**Databricks**](https://docs.databricks.com/aws/en/generative-ai/mcp/connect-external-services)

Managed MCP servers with Unity Catalog and Mosaic AIRequires user-specific URL. [Get your URL here](https://docs.databricks.com/aws/en/generative-ai/mcp/connect-external-services).

[**DataGrail**](https://docs.datagrail.io/docs/vera/vera-mcp/introduction-and-use)

Secure, production-ready AI orchestration for privacyRequires user-specific URL. [Get your URL here](https://docs.datagrail.io/docs/vera/vera-mcp/introduction-and-use).

[**Enterpret Wisdom**](https://helpcenter.enterpret.com/en/articles/12665166-wisdom-mcp-server)

Get answers from unified feedback of your customers.

Command

`claude mcp add --transport http enterpret-wisdom https://wisdom-api.enterpret.com/server/mcp `

[**Fever Event Discovery**](https://developer.feverup.com/)

Discover live entertainment events worldwide

Command

`claude mcp add --transport http fever-event-discovery https://data-search.apigw.feverup.com/mcp `

[**Glean**](https://docs.glean.com/administration/platform/mcp/about)

Bring enterprise context to Claude and your AI toolsRequires user-specific URL. [Get your URL here](https://docs.glean.com/administration/platform/mcp/about).

[**GoCardless**](https://developer.gocardless.com/developer-tools/mcp/)

Build GoCardless payment API integrations

Command

`claude mcp add --transport http gocardless https://mcp.gocardless.com `

[**GoDaddy**](https://developer.godaddy.com/mcp)

Search domains and check availability

Command

`claude mcp add --transport http godaddy https://api.godaddy.com/v1/domains/mcp`

[**Google Cloud BigQuery**](https://cloud.google.com/bigquery/docs/use-bigquery-mcp)

BigQuery: Advanced analytical insights for agents

Command

`claude mcp add --transport http bigquery https://bigquery.googleapis.com/mcp `

[**Granted**](https://grantedai.com/mcp)

Discover every grant opportunity in existence.

Command

`claude mcp add --transport http granted https://grantedai.com/api/mcp/mcp `

[**IFTTT**](https://ift.tt/ai_assistants)

Connect, control, and automate 1,000+ apps with IFTTT

Command

`claude mcp add --transport http ifttt https://ifttt.com/mcp `

[**Medidata**](https://learn.medidata.com/en-US/bundle/mcp-server-documentation/page/medidata_mcp_server_documentation.html)

Clinical trial software and site ranking tools

Command

`claude mcp add medidata --transport http https://mcp.imedidata.com/mcp`

[**Intercom**](https://developers.intercom.com/docs/guides/mcp)

Access to Intercom data for better customer insights

Command

`claude mcp add --transport http intercom https://mcp.intercom.com/mcp`

[**PlayMCP**](https://www.notion.so/2189b97b4888803dbbdcef264e7eff58)

Connect and use PlayMCP servers in your toolbox

Command

`claude mcp add playmcp --transport http https://playmcp.kakao.com/mcp`

[**Klaviyo**](https://developers.klaviyo.com/en/docs/klaviyo_mcp_server)

Report, strategize & create with real-time Klaviyo data

Command

`claude mcp add klaviyo --transport http https://mcp.klaviyo.com/mcp?include-mcp-app=true`

Search, compare and book flights, dynamic packages (flight + hotel) and hotels across global airlines and hotel suppliers.

Command

`claude mcp add lastminute-com --transport http https://mcp.lastminute.com/mcp`

[**LILT**](https://support.lilt.com/kb/LILT-mcp)

High-quality translation with human verification

Command

`claude mcp add --transport http lilt https://mcp.lilt.com/mcp `

[**Local Falcon**](https://github.com/local-falcon/mcp)

AI visibility and local search intelligence platform

Command

`claude mcp add --transport sse local-falcon https://mcp.localfalcon.com `

[**Lumin**](https://github.com/luminpdf/lumin-mcp-server)

Manage documents, send signature requests, and convert Markdown to PDF

Command

`claude mcp add --transport http lumin https://mcp.luminpdf.com/mcp `

[**Magic Patterns**](https://www.magicpatterns.com/docs/documentation/features/mcp-server/overview)

Discuss and iterate on Magic Patterns designs

Command

`claude mcp add --transport http magic-patterns https://mcp.magicpatterns.com/mcp `

[**MailerLite**](https://developers.mailerlite.com/mcp/#how-mcp-works)

Turn Claude into your email marketing assistant

Command

`claude mcp add --transport http mailerlite https://mcp.mailerlite.com/mcp `

[**Make**](https://developers.make.com/mcp-server/)

Run Make scenarios and manage your Make account

Command

`claude mcp add --transport http make https://mcp.make.com `

[**Melon**](https://tech.kakaoent.com/ai/using-melon-mcp-server-en/)

Browse music charts & your personalized music picks

Command

`claude mcp add melon --transport http https://mcp.melon.com/mcp/`

[**Mercury**](https://docs.mercury.com/docs/connecting-mercury-mcp)

Search, analyze and understand your finances on Mercury

Command

`claude mcp add mercury --transport http https://mcp.mercury.com/mcp`

[**Microsoft Learn**](https://learn.microsoft.com/en-us/training/support/mcp)

Search trusted Microsoft docs to power your development

Command

`claude mcp add --transport http microsoft-learn https://learn.microsoft.com/api/mcp `

[**Mixpanel**](https://docs.mixpanel.com/docs/features/mcp)

Analyze, query, and manage your Mixpanel data

Command

`claude mcp add --transport http mixpanel https://mcp.mixpanel.com/mcp `

[**MotherDuck**](https://motherduck.com/docs/sql-reference/mcp/)

Get answers from your data

Command

`claude mcp add motherduck --transport http https://api.motherduck.com/mcp`

[**NetSuite**](https://docs.oracle.com/en/cloud/saas/netsuite/ns-online-help/article_7200233106.html)

Connect Claude to NetSuite data for analysis & insightsRequires user-specific URL. [Get your URL here](https://system.netsuite.com/mcp/mcpinfo.nl).

[**Owkin**](https://docs.owkin.com/core-features-and-usage)

Interact with AI agents built for biology

Command

`claude mcp add owkin --transport http https://mcp.k.owkin.com/mcp`

[**Pigment**](https://kb.pigment.com/docs/mcp-server)

Analyze business dataRequires user-specific URL. [Get your URL here](https://kb.pigment.com/docs/mcp-server).

[**Postman**](https://github.com/postmanlabs/postman-mcp-server)

Give API context to your coding agents

Command

`claude mcp add --transport http postman https://mcp.postman.com/minimal `

Financial data and AI infrastructure for company research.

Command

`claude mcp add --transport http quartr https://mcp.quartr.com/mcp `

[**Ramp**](https://docs.ramp.com/developer-api/v1/guides/ramp-mcp-remote)

Search, access, and analyze your Ramp financial data

Command

`claude mcp add --transport http ramp https://ramp-mcp-remote.ramp.com/mcp`

[**Similarweb**](https://docs.similarweb.com/api-v5/mcp/mcp-setup)

Real time web, mobile app, and market data.

Command

`claude mcp add --transport http similarweb https://mcp.similarweb.com `

[**Slack**](https://docs.slack.dev/ai/mcp-server)

Send messages, create canvases, and fetch Slack data

Command

`claude mcp add --transport http --client-id 1601185624273.8899143856786 --callback-port 3118 slack https://mcp.slack.com/mcp `

[**Smartsheet**](https://help.smartsheet.com/articles/2483663-use-smartsheet-connector-claude)

Analyze and manage Smartsheet data with ClaudeRequires user-specific URL. [Get your URL here](https://help.smartsheet.com/articles/2483656-install-smartsheet-connector-claude#toc-get-started).

[**Snowflake**](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents-mcp)

Retrieve both structured and unstructured dataRequires user-specific URL. [Get your URL here](https://docs.snowflake.com/en/user-guide/admin-account-identifier#label-account-name-find).

[**AdisInsight**](https://adisinsight-mcp.springer.com/)

Pharmaceutical drug & clinical trial intelligence

Command

`claude mcp add --transport http adisinsight https://adisinsight-mcp.springer.com/mcp `

[**Square**](https://developer.squareup.com/docs/mcp)

Search and manage transaction, merchant, and payment data

Command

`claude mcp add --transport sse square https://mcp.squareup.com/sse `

[**Tavily**](https://docs.tavily.com/documentation/mcp)

Connect your AI agents to the web

Command

`claude mcp add --transport http tavily https://mcp.tavily.com/mcp `

[**pg-aiguide**](https://github.com/timescale/pg-aiguide)

Search pg and Tiger docs, learn database skills

Command

`claude mcp add --transport http pg-aiguide https://mcp.tigerdata.com/docs `

Find your ideal hotel at the best price.

Command

`claude mcp add --transport http trivago https://mcp.trivago.com/mcp`

[**Udemy Business**](https://business-support.udemy.com/hc/en-us/articles/34213384429335-How-to-Integrate-the-Udemy-Business-MCP-Server-With-Your-AI-Tool#h_01K9CA42YGCV1AVXPY1RKABKP1)

Search and explore skill-building resources

Command

`claude mcp add udemy-business --transport http https://api.udemy.com/mcp`

[**Pylon**](https://support.usepylon.com/articles/2407390554-connecting-to-the-pylon-mcp-server?lang=en)

Search and manage Pylon support issues

Command

`claude mcp add --transport http pylon https://mcp.usepylon.com/ `

[**Visier**](https://docs.visier.com/developer/agents/mcp/mcp-server.htm)

Find people, productivity and business impact insightsRequires user-specific URL. [Get your URL here](https://docs.visier.com/developer/agents/mcp/mcp-server-set-up.htm).

[**Webflow**](https://developers.webflow.com/mcp/v1.0.0/reference/overview)

Manage Webflow CMS, pages, assets and sites

Command

`claude mcp add --transport http webflow https://mcp.webflow.com/mcp `

[**WordPress.com**](https://developer.wordpress.com/docs/mcp/)

Secure AI access to manage your WordPress.com sites

Command

`claude mcp add wordpress-com --transport http https://public-api.wordpress.com/wpcom/v2/mcp/v1`

[**Workato**](https://docs.workato.com/en/mcp.html)

Automate workflows and connect your business appsRequires user-specific URL. [Get your URL here](https://app.workato.com/ai_hub/mcp).

[**Wyndham Hotels and Resorts**](https://www.wyndhamhotels.com/mcp-doc)

Discover the right Wyndham Hotel for you, faster

Command

`claude mcp add --transport http wyndham-hotels https://mcp.wyndhamhotels.com/claude/mcp `

[**Zapier**](https://docs.zapier.com/mcp/home)

Automate workflows across thousands of apps via conversation

Command

`claude mcp add zapier --transport http https://mcp.zapier.com/api/v1/connect`

[**Zoho Books**](https://help.zoho.com/portal/en/kb/mcp/getting-started/articles/zoho-mcp-help-documentation-29-9-2025)

Zoho Books MCP for Smart Finance Ops

Command

`claude mcp add --transport http zoho-books {url} `

[**Zoho CRM**](https://help.zoho.com/portal/en/kb/mcp/getting-started/articles/zoho-mcp-help-documentation-29-9-2025)

MCP Server for Zoho CRM Workflows

Command

`claude mcp add --transport http zoho-crm {url} `

[**Zoho Desk**](https://help.zoho.com/portal/en/kb/mcp/getting-started/articles/zoho-mcp-help-documentation-29-9-2025)

Zoho Desk MCP for Customer Support Automation

Command

`claude mcp add --transport http zoho-desk {url} `

[**Zoho Projects**](https://help.zoho.com/portal/en/kb/mcp/getting-started/articles/zoho-mcp-help-documentation-29-9-2025)

Zoho Projects MCP for Task & Project Automation

Command

`claude mcp add --transport http zoho-projects {url} `

[**ZoomInfo**](https://docs.zoominfo.com/docs/zi-api-mcp-overview/)

Enrich contacts & accounts with GTM intelligence

Command

`claude mcp add --transport http zoominfo https://mcp.zoominfo.com/mcp`

[**Jam**](https://jam.dev/docs/debug-a-jam/mcp)

Record screen and collect automatic context for issues

Command

`claude mcp add --transport http jam https://mcp.jam.dev/mcp `

[**PlanetScale**](https://planetscale.com/docs/connect/mcp)

Authenticated access to your Postgres and MySQL DB's

Command

`claude mcp add --transport http planetscale https://mcp.pscale.dev/mcp/planetscale `

[**Sentry**](https://docs.sentry.io/product/sentry-mcp/)

Search, query, and debug errors intelligently

Command

`claude mcp add --transport http sentry https://mcp.sentry.dev/mcp`

[**Craft**](https://documents.craft.me/jWeCVJrSfxFRuA)

Notes & second brain

Command

`claude mcp add --transport http craft https://mcp.craft.do/my/mcp `

[**MoSPI**](https://www.datainnovation.mospi.gov.in/mospi-mcp)

India's official statistics via natural language

Command

`claude mcp add --transport http mospi https://mcp.mospi.gov.in/ `

[**GraphOS MCP Tools**](https://www.apollographql.com/docs/graphos/platform/graphos-mcp-tools)

Search Apollo docs, specs, and best practices

Command

`claude mcp add --transport http graphos-tools https://mcp.apollographql.com `

[**Customer.io**](https://docs.customer.io/ai/mcp-server/)

Explore customer data and generate insights via ClaudeRequires user-specific URL. [Get your URL here](https://docs.customer.io/ai/mcp-server/).

[**PostHog**](https://posthog.com/docs/model-context-protocol)

Query, analyze, and manage your PostHog insights

Command

`claude mcp add --transport http posthog https://mcp.posthog.com/mcp `

[**Honeycomb**](https://docs.honeycomb.io/troubleshoot/product-lifecycle/beta/mcp/)

Query and explore observability data and SLOs

Command

`claude mcp add --transport http honeycomb https://mcp.honeycomb.io/mcp`

[**incident.io**](https://docs.incident.io/ai/remote-mcp)

See and manage everything in incident.io

Command

`claude mcp add incident-io --transport http https://mcp.incident.io/mcp`

[**n8n**](https://docs.n8n.io/advanced-ai/accessing-n8n-mcp-server/)

Access and run your n8n workflowsRequires user-specific URL. [Get your URL here](https://docs.n8n.io/advanced-ai/accessing-n8n-mcp-server/).

[**Outreach**](https://support.outreach.io/hc/en-us/articles/46370115253403-Outreach-MCP-Server)

Unleash your team's best performance with Outreach AI

Command

`claude mcp add --transport http outreach https://api.outreach.io/mcp/ `

[**Pendo**](https://support.pendo.io/hc/en-us/articles/41102236924955)

Connect to Pendo for product and user insightsRequires user-specific URL. [Get your URL here](https://support.pendo.io/hc/en-us/articles/41102236924955).

[**Sanity**](https://www.sanity.io/docs/ai/mcp-server)

Create, query, and manage structured content in Sanity

Command

`claude mcp add --transport http sanity https://mcp.sanity.io `

[**Starburst**](https://docs.starburst.io/starburst-galaxy/ai-workflows/mcp-server.html)

Securely retrieve data from your federated data sourcesRequires user-specific URL. [Get your URL here](https://docs.starburst.io/starburst-galaxy/ai-workflows/mcp-server.html).

[**Unthread**](https://docs.unthread.io/docs/unthread-ai/unthread-mcp)

Manage and automate your support tickets

Command

`claude mcp add --transport http unthread https://app.unthread.io/api/mcp `

[**Zocks**](https://help.zocks.io/en/articles/14075856-connect-to-the-zocks-mcp-server)

Analyze client conversations, patterns, and insights.

Command

`claude mcp add --transport http zocks https://mcp.zocks.io/v1/mcp `

[**Candid**](https://support.claude.com/en/articles/12923235-using-the-candid-connector-in-claude)

Research nonprofits and funders using Candid's data

Command

`claude mcp add candid --transport http https://mcp.candid.org/mcp`

[**Open Targets**](https://github.com/opentargets/open-targets-platform-mcp)

Drug target discovery and prioritisation platform

Command

`claude mcp add open-targets --transport http https://mcp.platform.opentargets.org/mcp`

[**Synapse.org**](https://github.com/susheel/synapse-mcp?tab=readme-ov-file#synapse-mcp-server)

Search and metadata tools for Synapse scientific data

Command

`claude mcp add synapse-org --transport http https://mcp.synapse.org/mcp`

[**Chronograph**](https://lp-help.chronograph.pe/article/735-chronograph-mcp)

Interact with your Chronograph data directly in Claude

Command

`claude mcp add --transport http chronograph https://ai.chronograph.pe/mcp`

[**Hex**](https://learn.hex.tech/docs/administration/mcp-server)

Answer questions with the Hex agentRequires user-specific URL. [Get your URL here](https://learn.hex.tech/docs/administration/mcp-server#connect-to-claude).

**특정 통합이 필요하신가요?** [GitHub에서 수백 개 이상의 MCP 서버를 찾거나](https://github.com/modelcontextprotocol/servers), [MCP SDK](https://modelcontextprotocol.io/quickstart/server) 를 사용하여 자신만의 서버를 구축하세요.

## MCP 서버 설치

MCP 서버는 필요에 따라 세 가지 방식으로 구성할 수 있습니다:

### 옵션 1: 원격 HTTP 서버 추가

HTTP 서버는 원격 MCP 서버에 연결하기 위한 권장 옵션입니다. 이는 클라우드 기반 서비스에 가장 널리 지원되는 전송 방식입니다.

```shellscript
# 기본 구문
claude mcp add --transport http <name> <url>

# 실제 예: Notion에 연결
claude mcp add --transport http notion https://mcp.notion.com/mcp

# Bearer 토큰을 사용한 예
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

### 옵션 2: 원격 SSE 서버 추가

SSE (Server-Sent Events) 전송은 더 이상 사용되지 않습니다. 가능한 경우 HTTP 서버를 사용하세요.

```shellscript
# 기본 구문
claude mcp add --transport sse <name> <url>

# 실제 예: Asana에 연결
claude mcp add --transport sse asana https://mcp.asana.com/sse

# 인증 헤더를 사용한 예
claude mcp add --transport sse private-api https://api.company.com/sse \
  --header "X-API-Key: your-key-here"
```

### 옵션 3: 로컬 stdio 서버 추가

Stdio 서버는 컴퓨터에서 로컬 프로세스로 실행됩니다. 시스템에 직접 액세스하거나 사용자 정의 스크립트가 필요한 도구에 이상적입니다.

```shellscript
# 기본 구문
claude mcp add [options] <name> -- <command> [args...]

# 실제 예: Airtable 서버 추가
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

**중요: 옵션 순서** 모든 옵션(`--transport`, `--env`, `--scope`, `--header`)은 서버 이름 **앞에** 와야 합니다. `--` (이중 대시)는 서버 이름과 MCP 서버에 전달되는 명령 및 인수를 구분합니다.예를 들어:
- `claude mcp add --transport stdio myserver -- npx server` → `npx server` 실행
- `claude mcp add --transport stdio --env KEY=value myserver -- python server.py --port 8080` → `KEY=value` 를 환경에서 `python server.py --port 8080` 실행
이는 Claude의 플래그와 서버의 플래그 간의 충돌을 방지합니다.

### 서버 관리

구성한 후에는 다음 명령으로 MCP 서버를 관리할 수 있습니다:

```shellscript
# 구성된 모든 서버 나열
claude mcp list

# 특정 서버의 세부 정보 가져오기
claude mcp get github

# 서버 제거
claude mcp remove github

# (Claude Code 내에서) 서버 상태 확인
/mcp
```

### 동적 도구 업데이트

Claude Code는 MCP `list_changed` 알림을 지원하므로 MCP 서버가 연결을 끊었다가 다시 연결할 필요 없이 사용 가능한 도구, 프롬프트 및 리소스를 동적으로 업데이트할 수 있습니다. MCP 서버가 `list_changed` 알림을 보내면 Claude Code는 해당 서버에서 사용 가능한 기능을 자동으로 새로 고칩니다.

### 채널을 사용한 메시지 푸시

MCP 서버는 또한 메시지를 세션에 직접 푸시할 수 있으므로 Claude는 CI 결과, 모니터링 경고 또는 채팅 메시지와 같은 외부 이벤트에 반응할 수 있습니다. 이를 활성화하려면 서버가 `claude/channel` 기능을 선언하고 시작 시 `--channels` 플래그로 옵트인합니다. 공식적으로 지원되는 채널을 사용하려면 [채널](https://code.claude.com/docs/ko/channels) 을 참조하거나, 자신만의 채널을 구축하려면 [채널 참조](https://code.claude.com/docs/ko/channels-reference) 를 참조하세요.

팁:
- `--scope` 플래그를 사용하여 구성이 저장되는 위치를 지정하세요:
	- `local` (기본값): 현재 프로젝트에서만 사용자에게만 사용 가능 (이전 버전에서는 `project` 라고 불렸음)
		- `project`: `.mcp.json` 파일을 통해 프로젝트의 모든 사람과 공유
		- `user`: 모든 프로젝트에서 사용자에게 사용 가능 (이전 버전에서는 `global` 이라고 불렸음)
- `--env` 플래그로 환경 변수를 설정하세요 (예: `--env KEY=value`)
- `MCP_TIMEOUT` 환경 변수를 사용하여 MCP 서버 시작 시간 초과를 구성하세요 (예: `MCP_TIMEOUT=10000 claude` 는 10초 시간 초과를 설정)
- Claude Code는 MCP 도구 출력이 10,000 토큰을 초과할 때 경고를 표시합니다. 이 제한을 늘리려면 `MAX_MCP_OUTPUT_TOKENS` 환경 변수를 설정하세요 (예: `MAX_MCP_OUTPUT_TOKENS=50000`)
- OAuth 2.0 인증이 필요한 원격 서버로 인증하려면 `/mcp` 를 사용하세요

**Windows 사용자**: 기본 Windows (WSL 아님)에서 `npx` 를 사용하는 로컬 MCP 서버는 올바른 실행을 보장하기 위해 `cmd /c` 래퍼가 필요합니다.

```shellscript
# 이는 Windows가 실행할 수 있는 command="cmd"를 생성합니다
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

`cmd /c` 래퍼가 없으면 Windows가 `npx` 를 직접 실행할 수 없기 때문에 “Connection closed” 오류가 발생합니다. (위의 참고 사항에서 `--` 매개변수에 대한 설명을 참조하세요.)

### 플러그인 제공 MCP 서버

[플러그인](https://code.claude.com/docs/ko/plugins) 은 MCP 서버를 번들로 제공할 수 있으며, 플러그인이 활성화되면 도구 및 통합을 자동으로 제공합니다. 플러그인 MCP 서버는 사용자 구성 서버와 동일하게 작동합니다. **플러그인 MCP 서버의 작동 방식**:
- 플러그인은 플러그인 루트의 `.mcp.json` 또는 `plugin.json` 에 인라인으로 MCP 서버를 정의합니다
- 플러그인이 활성화되면 MCP 서버가 자동으로 시작됩니다
- 플러그인 MCP 도구는 수동으로 구성된 MCP 도구와 함께 나타납니다
- 플러그인 서버는 플러그인 설치를 통해 관리됩니다 (`/mcp` 명령이 아님)
**플러그인 MCP 구성 예**: 플러그인 루트의 `.mcp.json`:

```json
{
  "mcpServers": {
    "database-tools": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
      "env": {
        "DB_URL": "${DB_URL}"
      }
    }
  }
}
```

또는 `plugin.json` 에 인라인:

```json
{
  "name": "my-plugin",
  "mcpServers": {
    "plugin-api": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/api-server",
      "args": ["--port", "8080"]
    }
  }
}
```

**플러그인 MCP 기능**:
- **자동 라이프사이클**: 세션 시작 시 활성화된 플러그인의 서버가 자동으로 연결됩니다. 세션 중에 플러그인을 활성화하거나 비활성화하면 `/reload-plugins` 를 실행하여 MCP 서버를 연결하거나 연결 해제합니다
- **환경 변수**: 번들된 플러그인 파일에 `${CLAUDE_PLUGIN_ROOT}` 사용 및 플러그인 업데이트를 유지하는 [지속적인 상태](https://code.claude.com/docs/ko/plugins-reference#persistent-data-directory) 에 `${CLAUDE_PLUGIN_DATA}` 사용
- **사용자 환경 액세스**: 수동으로 구성된 서버와 동일한 환경 변수에 액세스
- **여러 전송 유형**: stdio, SSE 및 HTTP 전송 지원 (전송 지원은 서버에 따라 다를 수 있음)
**플러그인 MCP 서버 보기**:

```shellscript
# Claude Code 내에서 플러그인 서버를 포함한 모든 MCP 서버 보기
/mcp
```

플러그인 서버는 플러그인에서 온 것을 나타내는 표시기와 함께 목록에 나타납니다. **플러그인 MCP 서버의 이점**:
- **번들 배포**: 도구 및 서버가 함께 패키징됨
- **자동 설정**: 수동 MCP 구성이 필요 없음
- **팀 일관성**: 플러그인이 설치되면 모든 사람이 동일한 도구를 얻음
플러그인과 함께 MCP 서버를 번들로 제공하는 방법에 대한 자세한 내용은 [플러그인 구성 요소 참조](https://code.claude.com/docs/ko/plugins-reference#mcp-servers) 를 참조하세요.

## MCP 설치 범위

MCP 서버는 서버 접근성 및 공유를 관리하기 위해 세 가지 다른 범위 수준에서 구성할 수 있습니다. 이러한 범위를 이해하면 특정 요구 사항에 맞게 서버를 구성하는 최선의 방법을 결정하는 데 도움이 됩니다.

### 로컬 범위

로컬 범위 서버는 기본 구성 수준을 나타내며 프로젝트 경로 아래 `~/.claude.json` 에 저장됩니다. 이러한 서버는 사용자에게만 비공개이며 현재 프로젝트 디렉토리 내에서 작업할 때만 액세스할 수 있습니다. 이 범위는 개인 개발 서버, 실험적 구성 또는 공유하면 안 되는 민감한 자격 증명을 포함하는 서버에 이상적입니다.

MCP 서버의 “로컬 범위”라는 용어는 일반 로컬 설정과 다릅니다. MCP 로컬 범위 서버는 `~/.claude.json` (홈 디렉토리)에 저장되고, 일반 로컬 설정은 `.claude/settings.local.json` (프로젝트 디렉토리)을 사용합니다. 설정 파일 위치에 대한 자세한 내용은 [설정](https://code.claude.com/docs/ko/settings#settings-files) 을 참조하세요.

```shellscript
# 로컬 범위 서버 추가 (기본값)
claude mcp add --transport http stripe https://mcp.stripe.com

# 명시적으로 로컬 범위 지정
claude mcp add --transport http stripe --scope local https://mcp.stripe.com
```

### 프로젝트 범위

프로젝트 범위 서버는 프로젝트 루트 디렉토리의 `.mcp.json` 파일에 구성을 저장하여 팀 협업을 가능하게 합니다. 이 파일은 버전 제어에 체크인되도록 설계되어 모든 팀 멤버가 동일한 MCP 도구 및 서비스에 액세스할 수 있도록 합니다. 프로젝트 범위 서버를 추가하면 Claude Code는 자동으로 이 파일을 생성하거나 적절한 구성 구조로 업데이트합니다.

```shellscript
# 프로젝트 범위 서버 추가
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp
```

결과 `.mcp.json` 파일은 표준화된 형식을 따릅니다:

```json
{
  "mcpServers": {
    "shared-server": {
      "command": "/path/to/server",
      "args": [],
      "env": {}
    }
  }
}
```

보안상의 이유로 Claude Code는 `.mcp.json` 파일의 프로젝트 범위 서버를 사용하기 전에 승인을 요청합니다. 이러한 승인 선택을 재설정해야 하는 경우 `claude mcp reset-project-choices` 명령을 사용하세요.

### 사용자 범위

사용자 범위 서버는 `~/.claude.json` 에 저장되며 교차 프로젝트 접근성을 제공하므로 컴퓨터의 모든 프로젝트에서 사용할 수 있으면서 사용자 계정에만 비공개입니다. 이 범위는 개인 유틸리티 서버, 개발 도구 또는 다양한 프로젝트에서 자주 사용하는 서비스에 적합합니다.

```shellscript
# 사용자 서버 추가
claude mcp add --transport http hubspot --scope user https://mcp.hubspot.com/anthropic
```

### 올바른 범위 선택

다음을 기반으로 범위를 선택하세요:
- **로컬 범위**: 개인 서버, 실험적 구성 또는 한 프로젝트에만 해당하는 민감한 자격 증명
- **프로젝트 범위**: 팀 공유 서버, 프로젝트 특정 도구 또는 협업에 필요한 서비스
- **사용자 범위**: 여러 프로젝트에서 필요한 개인 유틸리티, 개발 도구 또는 자주 사용하는 서비스

**MCP 서버는 어디에 저장되나요?**
- **사용자 및 로컬 범위**: `~/.claude.json` (`mcpServers` 필드 또는 프로젝트 경로 아래)
- **프로젝트 범위**: 프로젝트 루트의 `.mcp.json` (소스 제어에 체크인됨)
- **관리됨**: 시스템 디렉토리의 `managed-mcp.json` ([관리되는 MCP 구성](#managed-mcp-configuration) 참조)

### 범위 계층 및 우선순위

MCP 서버 구성은 명확한 우선순위 계층을 따릅니다. 동일한 이름의 서버가 여러 범위에 존재할 때 시스템은 로컬 범위 서버를 먼저 우선시하고, 그 다음 프로젝트 범위 서버, 마지막으로 사용자 범위 서버를 우선시하여 충돌을 해결합니다. 이 설계는 필요할 때 개인 구성이 공유 구성을 재정의할 수 있도록 합니다. 서버가 로컬로 구성되고 [claude.ai 커넥터](#use-mcp-servers-from-claude-ai) 를 통해서도 구성된 경우 로컬 구성이 우선순위를 가지며 커넥터 항목은 건너뜁니다.

### .mcp.json의 환경 변수 확장

Claude Code는 `.mcp.json` 파일의 환경 변수 확장을 지원하므로 팀이 구성을 공유하면서 머신 특정 경로 및 API 키와 같은 민감한 값에 대한 유연성을 유지할 수 있습니다. **지원되는 구문:**
- `${VAR}` - 환경 변수 `VAR` 의 값으로 확장
- `${VAR:-default}` - `VAR` 이 설정되면 확장, 그렇지 않으면 `default` 사용
**확장 위치:** 환경 변수는 다음에서 확장할 수 있습니다:
- `command` - 서버 실행 파일 경로
- `args` - 명령줄 인수
- `env` - 서버에 전달되는 환경 변수
- `url` - HTTP 서버 유형의 경우
- `headers` - HTTP 서버 인증의 경우
**변수 확장을 사용한 예**:

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

필수 환경 변수가 설정되지 않았고 기본값이 없으면 Claude Code는 구성을 구문 분석하지 못합니다.

## 실제 예

### 예: Sentry로 오류 모니터링

```shellscript
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
```

Sentry 계정으로 인증합니다:

```text
/mcp
```

그런 다음 프로덕션 문제를 디버깅합니다:

```text
지난 24시간 동안 가장 일반적인 오류는 무엇입니까?
```

```text
오류 ID abc123의 스택 추적을 보여주세요
```

```text
어떤 배포가 이러한 새로운 오류를 도입했습니까?
```

### 예: 코드 검토를 위해 GitHub에 연결

```shellscript
claude mcp add --transport http github https://api.githubcopilot.com/mcp/
```

필요한 경우 GitHub에 대해 “인증”을 선택하여 인증합니다:

```text
/mcp
```

그런 다음 GitHub로 작업합니다:

```text
PR #456을 검토하고 개선 사항을 제안하세요
```

```text
방금 발견한 버그에 대한 새 이슈를 생성하세요
```

```text
나에게 할당된 모든 열린 PR을 보여주세요
```

### 예: PostgreSQL 데이터베이스 쿼리

```shellscript
claude mcp add --transport stdio db -- npx -y @bytebase/dbhub \
  --dsn "postgresql://readonly:pass@prod.db.com:5432/analytics"
```

그런 다음 자연스럽게 데이터베이스를 쿼리합니다:

```text
이번 달 총 수익은 얼마입니까?
```

```text
주문 테이블의 스키마를 보여주세요
```

```text
지난 90일 동안 구매하지 않은 고객을 찾으세요
```

## 원격 MCP 서버로 인증

많은 클라우드 기반 MCP 서버는 인증이 필요합니다. Claude Code는 보안 연결을 위해 OAuth 2.0을 지원합니다.

팁:
- 인증 토큰은 안전하게 저장되고 자동으로 새로 고쳐집니다
- `/mcp` 메뉴에서 “Clear authentication”을 사용하여 액세스를 취소합니다
- 브라우저가 자동으로 열리지 않으면 제공된 URL을 복사하여 수동으로 엽니다
- 인증 후 브라우저 리디렉션이 연결 오류로 실패하면 브라우저의 주소 표시줄에서 전체 콜백 URL을 복사하여 Claude Code에 나타나는 URL 프롬프트에 붙여넣습니다
- OAuth 인증은 HTTP 서버에서 작동합니다

### 고정 OAuth 콜백 포트 사용

일부 MCP 서버는 미리 등록된 특정 리디렉션 URI가 필요합니다. 기본적으로 Claude Code는 OAuth 콜백을 위해 무작위로 사용 가능한 포트를 선택합니다. `--callback-port` 를 사용하여 포트를 고정하여 `http://localhost:PORT/callback` 형식의 사전 등록된 리디렉션 URI와 일치하도록 합니다. `--callback-port` 를 단독으로 사용할 수 있습니다 (동적 클라이언트 등록 포함) 또는 `--client-id` 와 함께 사용할 수 있습니다 (사전 구성된 자격 증명 포함).

```shellscript
# 동적 클라이언트 등록을 사용한 고정 콜백 포트
claude mcp add --transport http \
  --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

### 사전 구성된 OAuth 자격 증명 사용

일부 MCP 서버는 자동 OAuth 설정을 지원하지 않습니다. “Incompatible auth server: does not support dynamic client registration”과 같은 오류가 표시되면 서버에 사전 구성된 자격 증명이 필요합니다. Claude Code는 또한 동적 클라이언트 등록 대신 클라이언트 ID 메타데이터 문서 (CIMD)를 사용하는 서버를 지원하며 자동으로 검색합니다. 자동 검색이 실패하면 먼저 서버의 개발자 포털을 통해 OAuth 앱을 등록한 다음 서버를 추가할 때 자격 증명을 제공합니다.

팁:
- 클라이언트 시크릿은 구성에 저장되지 않고 시스템 키체인 (macOS) 또는 자격 증명 파일에 안전하게 저장됩니다
- 서버가 시크릿이 없는 공개 OAuth 클라이언트를 사용하는 경우 `--client-secret` 없이 `--client-id` 만 사용합니다
- `--callback-port` 는 `--client-id` 와 함께 또는 없이 사용할 수 있습니다
- 이러한 플래그는 HTTP 및 SSE 전송에만 적용됩니다. stdio 서버에는 영향을 주지 않습니다
- `claude mcp get <name>` 을 사용하여 OAuth 자격 증명이 서버에 대해 구성되었는지 확인합니다

### OAuth 메타데이터 검색 재정의

MCP 서버의 표준 OAuth 메타데이터 엔드포인트가 오류를 반환하지만 작동하는 OIDC 엔드포인트를 노출하는 경우 Claude Code에 특정 메타데이터 URL을 가리켜 기본 검색 체인을 우회할 수 있습니다. 기본적으로 Claude Code는 먼저 `/.well-known/oauth-protected-resource` 에서 RFC 9728 보호된 리소스 메타데이터를 확인한 다음 `/.well-known/oauth-authorization-server` 에서 RFC 8414 인증 서버 메타데이터로 돌아갑니다. `.mcp.json` 의 서버 구성의 `oauth` 객체에 `authServerMetadataUrl` 을 설정합니다:

```json
{
  "mcpServers": {
    "my-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "oauth": {
        "authServerMetadataUrl": "https://auth.example.com/.well-known/openid-configuration"
      }
    }
  }
}
```

URL은 `https://` 를 사용해야 합니다. 이 옵션은 Claude Code v2.1.64 이상이 필요합니다.

### 사용자 정의 헤더를 사용한 동적 인증

MCP 서버가 OAuth (예: Kerberos, 단기 토큰 또는 내부 SSO)가 아닌 다른 인증 체계를 사용하는 경우 `headersHelper` 를 사용하여 연결 시간에 요청 헤더를 생성합니다. Claude Code는 명령을 실행하고 출력을 연결 헤더에 병합합니다.

```json
{
  "mcpServers": {
    "internal-api": {
      "type": "http",
      "url": "https://mcp.internal.example.com",
      "headersHelper": "/opt/bin/get-mcp-auth-headers.sh"
    }
  }
}
```

명령은 인라인일 수도 있습니다:

```json
{
  "mcpServers": {
    "internal-api": {
      "type": "http",
      "url": "https://mcp.internal.example.com",
      "headersHelper": "echo '{\"Authorization\": \"Bearer '\"$(get-token)\"'\"}'"
    }
  }
}
```

**요구 사항:**
- 명령은 JSON 객체의 문자열 키-값 쌍을 stdout에 작성해야 합니다
- 명령은 10초 시간 초과를 사용하여 셸에서 실행됩니다
- 동적 헤더는 동일한 이름의 정적 `headers` 를 재정의합니다
헬퍼는 각 연결 (세션 시작 및 재연결 시)에서 새로 실행됩니다. 캐싱이 없으므로 스크립트는 토큰 재사용을 담당합니다. Claude Code는 헬퍼를 실행할 때 다음 환경 변수를 설정합니다:

| 변수 | 값 |
| --- | --- |
| `CLAUDE_CODE_MCP_SERVER_NAME` | MCP 서버의 이름 |
| `CLAUDE_CODE_MCP_SERVER_URL` | MCP 서버의 URL |

이를 사용하여 여러 MCP 서버를 제공하는 단일 헬퍼 스크립트를 작성합니다.

`headersHelper` 는 임의의 셸 명령을 실행합니다. 프로젝트 또는 로컬 범위에서 정의될 때 작업 공간 신뢰 대화 상자를 수락한 후에만 실행됩니다.

## JSON 구성에서 MCP 서버 추가

MCP 서버에 대한 JSON 구성이 있는 경우 직접 추가할 수 있습니다:

팁:
- JSON이 셸에서 올바르게 이스케이프되었는지 확인합니다
- JSON은 MCP 서버 구성 스키마를 준수해야 합니다
- `--scope user` 를 사용하여 프로젝트 특정 구성 대신 사용자 구성에 서버를 추가할 수 있습니다

## Claude Desktop에서 MCP 서버 가져오기

Claude Desktop에서 MCP 서버를 이미 구성한 경우 가져올 수 있습니다:

팁:
- 이 기능은 macOS 및 Windows Subsystem for Linux (WSL)에서만 작동합니다
- 이러한 플랫폼의 표준 위치에서 Claude Desktop 구성 파일을 읽습니다
- `--scope user` 플래그를 사용하여 사용자 구성에 서버를 추가합니다
- 가져온 서버는 Claude Desktop과 동일한 이름을 갖습니다
- 동일한 이름의 서버가 이미 존재하면 숫자 접미사가 붙습니다 (예: `server_1`)

## Claude.ai에서 MCP 서버 사용

[Claude.ai](https://claude.ai/) 계정으로 Claude Code에 로그인한 경우 Claude.ai에서 추가한 MCP 서버는 Claude Code에서 자동으로 사용 가능합니다: Claude Code에서 claude.ai MCP 서버를 비활성화하려면 `ENABLE_CLAUDEAI_MCP_SERVERS` 환경 변수를 `false` 로 설정합니다:

```shellscript
ENABLE_CLAUDEAI_MCP_SERVERS=false claude
```

## Claude Code를 MCP 서버로 사용

Claude Code 자체를 다른 애플리케이션이 연결할 수 있는 MCP 서버로 사용할 수 있습니다:

```shellscript
# Claude를 stdio MCP 서버로 시작
claude mcp serve
```

claude\_desktop\_config.json에 이 구성을 추가하여 Claude Desktop에서 사용할 수 있습니다:

```json
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "claude",
      "args": ["mcp", "serve"],
      "env": {}
    }
  }
}
```

**실행 파일 경로 구성**: `command` 필드는 Claude Code 실행 파일을 참조해야 합니다. `claude` 명령이 시스템의 PATH에 없으면 실행 파일의 전체 경로를 지정해야 합니다.전체 경로를 찾으려면:

```shellscript
which claude
```

그런 다음 구성에서 전체 경로를 사용합니다:

```json
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "/full/path/to/claude",
      "args": ["mcp", "serve"],
      "env": {}
    }
  }
}
```

올바른 실행 파일 경로가 없으면 `spawn claude ENOENT` 와 같은 오류가 발생합니다.

팁:
- 서버는 View, Edit, LS 등과 같은 Claude의 도구에 대한 액세스를 제공합니다
- Claude Desktop에서 Claude에게 디렉토리의 파일을 읽고, 편집하는 등을 요청해 보세요
- 이 MCP 서버는 Claude Code의 도구만 MCP 클라이언트에 노출하므로 클라이언트는 개별 도구 호출에 대한 사용자 확인을 구현할 책임이 있습니다.

## MCP 출력 제한 및 경고

MCP 도구가 큰 출력을 생성할 때 Claude Code는 토큰 사용량을 관리하여 대화 컨텍스트가 압도되지 않도록 합니다:
- **출력 경고 임계값**: Claude Code는 MCP 도구 출력이 10,000 토큰을 초과할 때 경고를 표시합니다
- **구성 가능한 제한**: `MAX_MCP_OUTPUT_TOKENS` 환경 변수를 사용하여 최대 허용 MCP 출력 토큰을 조정할 수 있습니다
- **기본 제한**: 기본 최대값은 25,000 토큰입니다
큰 출력을 생성하는 도구의 제한을 늘리려면:

```shellscript
# MCP 도구 출력의 제한을 높게 설정
export MAX_MCP_OUTPUT_TOKENS=50000
claude
```

이는 다음을 수행하는 MCP 서버로 작업할 때 특히 유용합니다:
- 대규모 데이터 세트 또는 데이터베이스 쿼리
- 상세한 보고서 또는 문서 생성
- 광범위한 로그 파일 또는 디버깅 정보 처리

특정 MCP 서버에서 자주 출력 경고가 발생하면 제한을 늘리거나 서버를 구성하여 응답을 페이지 매김하거나 필터링하는 것을 고려하세요.

## MCP 리소스 요청에 응답

MCP 서버는 작업 중에 구조화된 입력을 요청할 수 있습니다. 서버가 자체적으로 얻을 수 없는 정보가 필요할 때 Claude Code는 대화형 대화 상자를 표시하고 응답을 서버에 다시 전달합니다. 사용자 측에서 구성이 필요하지 않습니다: 서버가 요청할 때 리소스 요청 대화 상자가 자동으로 나타납니다. 서버는 두 가지 방식으로 입력을 요청할 수 있습니다:
- **양식 모드**: Claude Code는 서버에서 정의한 양식 필드가 있는 대화 상자를 표시합니다 (예: 사용자 이름 및 암호 프롬프트). 필드를 입력하고 제출합니다.
- **URL 모드**: Claude Code는 인증 또는 승인을 위해 브라우저 URL을 엽니다. 브라우저에서 흐름을 완료한 다음 CLI에서 확인합니다.
리소스 요청에 자동으로 응답하려면 [`Elicitation` 훅](https://code.claude.com/docs/ko/hooks#Elicitation) 을 사용하세요. 리소스 요청을 사용하는 MCP 서버를 구축하는 경우 [MCP 리소스 요청 사양](https://modelcontextprotocol.io/docs/learn/client-concepts#elicitation) 에서 프로토콜 세부 정보 및 스키마 예를 참조하세요.

## MCP 리소스 사용

MCP 서버는 파일을 참조하는 방식과 유사하게 @ 멘션을 사용하여 참조할 수 있는 리소스를 노출할 수 있습니다.

### MCP 리소스 참조

팁:
- 리소스는 참조될 때 자동으로 가져와지고 첨부 파일로 포함됩니다
- 리소스 경로는 @ 멘션 자동 완성에서 퍼지 검색 가능합니다
- Claude Code는 서버가 지원할 때 MCP 리소스를 나열하고 읽을 수 있는 도구를 자동으로 제공합니다
- 리소스는 MCP 서버가 제공하는 모든 유형의 콘텐츠를 포함할 수 있습니다 (텍스트, JSON, 구조화된 데이터 등)

## MCP Tool Search로 확장

Tool Search는 MCP 컨텍스트 사용량을 낮게 유지하여 도구 정의를 세션 시작까지 연기합니다. 도구 이름만 로드되므로 더 많은 MCP 서버를 추가해도 컨텍스트 윈도우에 미치는 영향이 최소화됩니다.

### 작동 방식

Tool Search는 기본적으로 활성화됩니다. MCP 도구는 미리 로드되지 않고 연기되며, Claude는 검색 도구를 사용하여 작업에 필요할 때 관련 도구를 검색합니다. Claude가 실제로 사용하는 도구만 컨텍스트에 들어갑니다. 관점에서 MCP 도구는 이전과 정확히 동일하게 계속 작동합니다. 임계값 기반 로딩을 선호하는 경우 `ENABLE_TOOL_SEARCH=auto` 를 설정하여 컨텍스트 윈도우의 10% 이내에 맞을 때 스키마를 미리 로드하고 오버플로우만 연기합니다. 모든 옵션은 [Tool Search 구성](#configure-tool-search) 을 참조하세요.

### MCP 서버 작성자용

MCP 서버를 구축하는 경우 Tool Search가 활성화되면 서버 지침 필드가 더 유용해집니다. 서버 지침은 Claude가 [skills](https://code.claude.com/docs/ko/skills) 의 작동 방식과 유사하게 도구를 검색할 시기를 이해하는 데 도움이 됩니다. 다음을 설명하는 명확하고 설명적인 서버 지침을 추가합니다:
- 도구가 처리하는 작업의 범주
- Claude가 도구를 검색해야 할 때
- 서버가 제공하는 주요 기능
Claude Code는 도구 설명 및 서버 지침을 각각 2KB에서 자릅니다. 자르기를 피하려면 간결하게 유지하고 중요한 세부 정보를 시작 부분에 배치합니다.

### Tool Search 구성

Tool Search는 기본적으로 활성화됩니다: MCP 도구는 연기되고 필요에 따라 검색됩니다. `ANTHROPIC_BASE_URL` 이 비 자사 호스트를 가리킬 때 Tool Search는 기본적으로 비활성화됩니다. 대부분의 프록시가 `tool_reference` 블록을 전달하지 않기 때문입니다. 프록시가 전달하는 경우 `ENABLE_TOOL_SEARCH` 를 명시적으로 설정하세요. 이 기능은 `tool_reference` 블록을 지원하는 모델이 필요합니다: Sonnet 4 이상 또는 Opus 4 이상. Haiku 모델은 Tool Search를 지원하지 않습니다. `ENABLE_TOOL_SEARCH` 환경 변수로 Tool Search 동작을 제어합니다:

| 값 | 동작 |
| --- | --- |
| (설정되지 않음) | 모든 MCP 도구 연기되고 필요에 따라 로드됨. `ANTHROPIC_BASE_URL` 이 비 자사 호스트일 때 미리 로드로 돌아감 |
| `true` | 모든 MCP 도구 연기, 비 자사 `ANTHROPIC_BASE_URL` 포함 |
| `auto` | 임계값 모드: 도구가 컨텍스트 윈도우의 10% 이내에 맞으면 미리 로드, 그렇지 않으면 연기 |
| `auto:<N>` | 사용자 정의 백분율을 사용한 임계값 모드, `<N>` 은 0-100 (예: `auto:5` 는 5%) |
| `false` | 모든 MCP 도구 미리 로드, 연기 없음 |

```shellscript
# 사용자 정의 5% 임계값 사용
ENABLE_TOOL_SEARCH=auto:5 claude

# Tool Search 완전히 비활성화
ENABLE_TOOL_SEARCH=false claude
```

또는 [settings.json `env` 필드](https://code.claude.com/docs/ko/settings#available-settings) 에서 값을 설정합니다. `ToolSearch` 도구를 특별히 비활성화할 수도 있습니다:

```json
{
  "permissions": {
    "deny": ["ToolSearch"]
  }
}
```

## MCP 프롬프트를 명령으로 사용

MCP 서버는 Claude Code에서 명령으로 사용 가능하게 되는 프롬프트를 노출할 수 있습니다.

### MCP 프롬프트 실행

팁:
- MCP 프롬프트는 연결된 서버에서 동적으로 검색됩니다
- 인수는 프롬프트의 정의된 매개변수를 기반으로 구문 분석됩니다
- 프롬프트 결과는 대화에 직접 주입됩니다
- 서버 및 프롬프트 이름은 정규화됩니다 (공백은 밑줄이 됨)

## 관리되는 MCP 구성

MCP 서버에 대한 중앙 집중식 제어가 필요한 조직의 경우 Claude Code는 두 가지 구성 옵션을 지원합니다:
1. **`managed-mcp.json` 을 사용한 독점 제어**: 사용자가 수정하거나 확장할 수 없는 고정된 MCP 서버 세트 배포
2. **허용 목록/거부 목록을 사용한 정책 기반 제어**: 사용자가 자신의 서버를 추가할 수 있지만 허용되는 서버를 제한
이러한 옵션을 통해 IT 관리자는 다음을 수행할 수 있습니다:
- **직원이 액세스할 수 있는 MCP 서버 제어**: 조직 전체에 표준화된 승인된 MCP 서버 세트 배포
- **승인되지 않은 MCP 서버 방지**: 사용자가 승인되지 않은 MCP 서버를 추가하지 못하도록 제한
- **MCP 완전히 비활성화**: 필요한 경우 MCP 기능을 완전히 제거

### 옵션 1: managed-mcp.json을 사용한 독점 제어

`managed-mcp.json` 파일을 배포하면 모든 MCP 서버에 대한 **독점 제어** 를 갖습니다. 사용자는 이 파일에 정의된 서버 이외의 MCP 서버를 추가, 수정 또는 사용할 수 없습니다. 이는 완전한 제어를 원하는 조직에 가장 간단한 방법입니다. 시스템 관리자는 구성 파일을 시스템 전체 디렉토리에 배포합니다:
- macOS: `/Library/Application Support/ClaudeCode/managed-mcp.json`
- Linux 및 WSL: `/etc/claude-code/managed-mcp.json`
- Windows: `C:\Program Files\ClaudeCode\managed-mcp.json`

이는 시스템 전체 경로입니다 (`~/Library/...`와 같은 사용자 홈 디렉토리가 아님). IT 관리자가 배포하기 위해 관리자 권한이 필요합니다.

`managed-mcp.json` 파일은 표준 `.mcp.json` 파일과 동일한 형식을 사용합니다:

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    },
    "sentry": {
      "type": "http",
      "url": "https://mcp.sentry.dev/mcp"
    },
    "company-internal": {
      "type": "stdio",
      "command": "/usr/local/bin/company-mcp-server",
      "args": ["--config", "/etc/company/mcp-config.json"],
      "env": {
        "COMPANY_API_URL": "https://internal.company.com"
      }
    }
  }
}
```

### 옵션 2: 허용 목록 및 거부 목록을 사용한 정책 기반 제어

독점 제어를 하는 대신 관리자는 사용자가 자신의 MCP 서버를 구성할 수 있도록 허용하면서 허용되는 서버에 제한을 적용할 수 있습니다. 이 방법은 [관리되는 설정 파일](https://code.claude.com/docs/ko/settings#settings-files) 의 `allowedMcpServers` 및 `deniedMcpServers` 를 사용합니다.

**옵션 선택**: 사용자 사용자 정의 없이 고정된 서버 세트를 배포하려면 옵션 1 (`managed-mcp.json`)을 사용합니다. 사용자가 정책 제약 내에서 자신의 서버를 추가할 수 있도록 하려면 옵션 2 (허용 목록/거부 목록)를 사용합니다.

#### 제한 옵션

허용 목록 또는 거부 목록의 각 항목은 세 가지 방식으로 서버를 제한할 수 있습니다:
1. **서버 이름으로** (`serverName`): 서버의 구성된 이름과 일치
2. **명령으로** (`serverCommand`): stdio 서버를 시작하는 데 사용되는 정확한 명령 및 인수와 일치
3. **URL 패턴으로** (`serverUrl`): 와일드카드 지원을 사용하여 원격 서버 URL과 일치
**중요**: 각 항목은 `serverName`, `serverCommand` 또는 `serverUrl` 중 정확히 하나를 가져야 합니다.

#### 구성 예

```json
{
  "allowedMcpServers": [
    // 서버 이름으로 허용
    { "serverName": "github" },
    { "serverName": "sentry" },

    // 정확한 명령으로 허용 (stdio 서버의 경우)
    { "serverCommand": ["npx", "-y", "@modelcontextprotocol/server-filesystem"] },
    { "serverCommand": ["python", "/usr/local/bin/approved-server.py"] },

    // URL 패턴으로 허용 (원격 서버의 경우)
    { "serverUrl": "https://mcp.company.com/*" },
    { "serverUrl": "https://*.internal.corp/*" }
  ],
  "deniedMcpServers": [
    // 서버 이름으로 차단
    { "serverName": "dangerous-server" },

    // 정확한 명령으로 차단 (stdio 서버의 경우)
    { "serverCommand": ["npx", "-y", "unapproved-package"] },

    // URL 패턴으로 차단 (원격 서버의 경우)
    { "serverUrl": "https://*.untrusted.com/*" }
  ]
}
```

#### 명령 기반 제한의 작동 방식

**정확한 일치**:
- 명령 배열은 **정확히** 일치해야 합니다 - 명령과 올바른 순서의 모든 인수
- 예: `["npx", "-y", "server"]` 는 `["npx", "server"]` 또는 `["npx", "-y", "server", "--flag"]` 와 일치하지 않습니다
**Stdio 서버 동작**:
- 허용 목록에 **모든** `serverCommand` 항목이 포함되면 stdio 서버는 해당 명령 중 하나와 일치해야 합니다
- Stdio 서버는 명령 제한이 있을 때 이름만으로는 통과할 수 없습니다
- 이는 관리자가 실행할 수 있는 명령을 적용할 수 있도록 합니다
**비 stdio 서버 동작**:
- 원격 서버 (HTTP, SSE, WebSocket)는 허용 목록에 `serverUrl` 항목이 있을 때 URL 기반 일치를 사용합니다
- URL 항목이 없으면 원격 서버는 이름 기반 일치로 돌아갑니다
- 명령 제한은 원격 서버에 적용되지 않습니다

#### URL 기반 제한의 작동 방식

URL 패턴은 `*` 를 사용하여 와일드카드를 지원하여 모든 문자 시퀀스와 일치합니다. 이는 전체 도메인 또는 하위 도메인을 허용하는 데 유용합니다. **와일드카드 예**:
- `https://mcp.company.com/*` - 특정 도메인의 모든 경로 허용
- `https://*.example.com/*` - example.com의 모든 하위 도메인 허용
- `http://localhost:*/*` - localhost의 모든 포트 허용
**원격 서버 동작**:
- 허용 목록에 **모든** `serverUrl` 항목이 포함되면 원격 서버는 해당 URL 패턴 중 하나와 일치해야 합니다
- 원격 서버는 URL 제한이 있을 때 이름만으로는 통과할 수 없습니다
- 이는 관리자가 허용되는 원격 엔드포인트를 적용할 수 있도록 합니다

```json
{
  "allowedMcpServers": [
    { "serverUrl": "https://mcp.company.com/*" },
    { "serverUrl": "https://*.internal.corp/*" }
  ]
}
```

**결과**:
- `https://mcp.company.com/api` 의 HTTP 서버: ✅ 허용됨 (URL 패턴과 일치)
- `https://api.internal.corp/mcp` 의 HTTP 서버: ✅ 허용됨 (와일드카드 하위 도메인과 일치)
- `https://external.com/mcp` 의 HTTP 서버: ❌ 차단됨 (URL 패턴과 일치하지 않음)
- 모든 명령의 Stdio 서버: ❌ 차단됨 (일치할 이름 또는 명령 항목 없음)

```json
{
  "allowedMcpServers": [
    { "serverCommand": ["npx", "-y", "approved-package"] }
  ]
}
```

**결과**:
- `["npx", "-y", "approved-package"]` 를 사용한 Stdio 서버: ✅ 허용됨 (명령과 일치)
- `["node", "server.js"]` 를 사용한 Stdio 서버: ❌ 차단됨 (명령과 일치하지 않음)
- “my-api”라는 이름의 HTTP 서버: ❌ 차단됨 (일치할 이름 항목 없음)

```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverCommand": ["npx", "-y", "approved-package"] }
  ]
}
```

**결과**:
- `["npx", "-y", "approved-package"]` 를 사용한 “local-tool”이라는 Stdio 서버: ✅ 허용됨 (명령과 일치)
- `["node", "server.js"]` 를 사용한 “local-tool”이라는 Stdio 서버: ❌ 차단됨 (명령 항목이 있지만 일치하지 않음)
- `["node", "server.js"]` 를 사용한 “github”라는 Stdio 서버: ❌ 차단됨 (명령 항목이 있을 때 stdio 서버는 명령과 일치해야 함)
- “github”라는 이름의 HTTP 서버: ✅ 허용됨 (이름과 일치)
- “other-api”라는 이름의 HTTP 서버: ❌ 차단됨 (이름과 일치하지 않음)

```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverName": "internal-tool" }
  ]
}
```

**결과**:
- 모든 명령을 사용한 “github”라는 Stdio 서버: ✅ 허용됨 (명령 제한 없음)
- 모든 명령을 사용한 “internal-tool”이라는 Stdio 서버: ✅ 허용됨 (명령 제한 없음)
- “github”라는 이름의 HTTP 서버: ✅ 허용됨 (이름과 일치)
- “other”라는 이름의 모든 서버: ❌ 차단됨 (이름과 일치하지 않음)

#### 허용 목록 동작 (allowedMcpServers)

- `undefined` (기본값): 제한 없음 - 사용자는 모든 MCP 서버를 구성할 수 있습니다
- 빈 배열 `[]`: 완전한 잠금 - 사용자는 MCP 서버를 구성할 수 없습니다
- 항목 목록: 사용자는 이름, 명령 또는 URL 패턴과 일치하는 서버만 구성할 수 있습니다

#### 거부 목록 동작 (deniedMcpServers)

- `undefined` (기본값): 차단된 서버 없음
- 빈 배열 `[]`: 차단된 서버 없음
- 항목 목록: 지정된 서버는 모든 범위에서 명시적으로 차단됩니다

#### 중요한 참고 사항

- **옵션 1과 옵션 2를 결합할 수 있습니다**: `managed-mcp.json` 이 존재하면 독점 제어를 가지며 사용자는 서버를 추가할 수 없습니다. 허용 목록/거부 목록은 여전히 관리되는 서버 자체에 적용됩니다.
- **거부 목록이 절대 우선순위를 갖습니다**: 서버가 거부 목록 항목과 일치하면 (이름, 명령 또는 URL로) 허용 목록에 있어도 차단됩니다
- 이름 기반, 명령 기반 및 URL 기반 제한이 함께 작동합니다: 서버는 이름 항목, 명령 항목 또는 URL 패턴과 일치하면 통과합니다 (거부 목록으로 차단되지 않는 한)

**`managed-mcp.json` 사용 시**: 사용자는 `claude mcp add` 또는 구성 파일을 통해 MCP 서버를 추가할 수 없습니다. `allowedMcpServers` 및 `deniedMcpServers` 설정은 여전히 실제로 로드되는 관리되는 서버를 필터링하기 위해 적용됩니다.