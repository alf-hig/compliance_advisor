# Deployment Guide - Business Insurance Compliance Advisor

This guide explains how to deploy the Business Insurance Compliance Advisor to Render.com.

## Prerequisites

1. A [Render.com](https://render.com) account
2. Your code pushed to a GitHub repository
3. Rails Master Key (see below)

## Setup Instructions

### 1. Prepare Your Repository

Ensure all the files are committed to your GitHub repository:
```bash
git add .
git commit -m "Add Render deployment configuration"
git push origin main
```

### 2. Set Up Rails Master Key

Your Rails application needs a master key for encryption. Generate one if you don't have it:

```bash
# Generate a new master key (this will create config/master.key)
bundle exec rails credentials:edit
```

**Important:** The `config/master.key` file should NOT be committed to git (it's in .gitignore). You'll need to add this as an environment variable in Render.

### 3. Deploy to Render

1. **Connect Your Repository:**
   - Log in to [Render.com](https://render.com)
   - Click "New +" and select "Blueprint"
   - Connect your GitHub repository containing this Rails app
   - Render will automatically detect the `render.yaml` file

2. **Set Environment Variables:**
   - In the Render dashboard, go to your web service settings
   - Add the `RAILS_MASTER_KEY` environment variable:
     - Key: `RAILS_MASTER_KEY`
     - Value: Contents of your `config/master.key` file

3. **Deploy:**
   - Render will automatically start building and deploying your application
   - The build process will:
     - Install Ruby gems
     - Precompile assets
     - Run database migrations
     - Seed the database with initial questions and insurance requirements

### 4. Access Your Application

Once deployed, your application will be available at:
`https://compliance-advisor.onrender.com`

## What Gets Deployed

The Render configuration (`render.yaml`) sets up:

- **Web Service:** Rails application with Puma server
- **Database:** PostgreSQL database (free tier)
- **Environment:** Production environment with proper security settings
- **Health Checks:** Automatic health monitoring
- **Auto-scaling:** Configured for the free tier

## Features Available

✅ **Landing Page:** Compelling introduction to the service  
✅ **Assessment Wizard:** Interactive questionnaire with progressive disclosure  
✅ **Results Dashboard:** Personalized insurance requirements with cost estimates  
✅ **Mobile Responsive:** Optimized for all device sizes  
✅ **Static Pages:** About, Privacy Policy, Terms of Service  

## Monitoring and Maintenance

### View Logs
```bash
# In Render dashboard, go to your service > Logs
```

### Manual Database Operations
```bash
# Connect to your database through Render's shell
# Go to your service > Shell tab
bundle exec rails console
```

### Update Deployment
Simply push changes to your main branch:
```bash
git add .
git commit -m "Update application"
git push origin main
```

Render will automatically redeploy your application.

## Cost Information

This configuration uses Render's free tier:
- **Web Service:** Free (750 hours/month, sleeps after 15 min of inactivity)
- **PostgreSQL:** Free (90 day limit, then $7/month)
- **Disk Storage:** 1GB included

## Troubleshooting

### Build Failures
- Check the build logs in Render dashboard
- Ensure all gems are properly specified in Gemfile
- Verify Ruby version compatibility

### Database Issues
- Check that `RAILS_MASTER_KEY` environment variable is set
- Verify database connection strings
- Review migration logs

### Application Errors
- Check application logs in Render dashboard
- Verify all environment variables are set correctly
- Test locally first before deploying

## Support

For Render-specific issues, check:
- [Render Documentation](https://render.com/docs)
- [Render Community](https://community.render.com/)

For application-specific issues, review the application logs and error messages.
