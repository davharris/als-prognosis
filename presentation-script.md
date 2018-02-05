# Predicting ALS symptom progression

Hi, I'm Dave Harris, and today I'll be telling you about my work on forcasting the progression of ALS (also known as Lou Gehrig's disease), which is a neurodegenerative condition that causes paralysis. 

It's a lot more common than many people realize: the lifetime risk is about 1 in 400 people.

# It's hard

For many patients, one of the most difficult aspects of the disease is the uncertainty: patients want to know how long they have until they'll need a wheelchair or until they won't be able to speak, but even expert physicians have difficulty predicting how quickly a patient's ALS symptoms will progress.

# Famous folks

Just to give a sense of how variable this disease is, here are two of the most famous people with the disease. Lou Gehrig lived less than two years after he was diagnosed, which is on the short side, while Stephen Hawking is still alive more than 50 years later. There's a lot of research on classifying subtypes of the disease, but it's still hard to say where a given patient will fall on this spectrum.

# How sick will I be next year?

To try and address this, I downloaded a collection of patient histories from the PRO-ACT database. I'll be focusing on this "functional rating scale", which describes patients' ability to perform 10 basic tasks (such as walking).

Each time someone takes this test, they report their ability to perform these tasks on a scale from 4 (which indicates full function) to zero (which indicates no function). 

For example, if the task is Walking, then "4" is normal walking, "2" is walking with a cane, and "0" is when you can't move your legs at all.

# The data

Okay, so we have time series data for each patient for 10 different types of daily tasks, 5 of which I've shown here.

How do we use this information to make predictions? 

There aren't any standard statistics or machine learning packages that are well-suited to this sort of problem, which involves ten different response variables over time, so I had to build my own statistical model.

I used the Stan probabilistic programming language to specify the model, which I'll build up to over the next few slides, starting with the "Walking" task.

# Logistic regression / ordered logit

So, the simplest way to model Walking would be logistic regression. As time-since-onset increases, the probability that a given subject will be able to walk goes down.

To extend this model to five categories, we can use an extension of logistic regression called an ordered logit model. Its predictions look like this.

Now, we can start to make useful predictions. Let's say a subject comes in to a doctor's office three times, about 1 year after onset. Their survey responses can tell us enough to start making personalized predictions. For example, here are the predictions for a patient that had no trouble walking 1 year in, and here are the predictions for someone that was advancing more quickly.

In the Stan model, this all happens using random effects for each patient's slopes and intercepts. Because the model is Bayesian, we get automatically a range of possible progression rates for each patient.

One thing that helps a lot is that the progression rates are tightly correlated across tasks.  For instance, when subjects start losing the ability to climb stairs, that provides the model with a nice nice "early warning system" for the ability to walk on flat ground.  

These other clusters of highly-correlated also help the model share information across tasks when it's making predictions.

# App

Once we have our predictions, we need to present them to doctors and patients.  So I built an app lets the doctor pull up a dashboard for each patient.  

Here is some demographic and medical information.

Below, predicted scores over the next two years are grouped by type: respiratory, bulbar (which means mouth and throat), and motor tasks involving the arms and legs. At a glance, the doctor can see that the patient can expect to lose additional motor function, but that they'll probably continue eating and breathing okay.

Now let's say the patient wants to know if they'll need a wheelchair one year from now. Clicking the "walking" task brings up their likely scores. This area marked "two" corresponds to walking with assistance like a cane, so that's the most likely scenario, but they could still lose that ability at any time.  

The doctor can also move their mouse to see the patient's projected scores at different points in the future.

# Model validation

Finally, we should make sure that the model's predictions are actually worth showing to doctors.

# The prediction task

To do this, I set up a prediction task. Here, time is the x-axis.

First, I showed the model the complete histories from a few hundred subjects, which included 12 surveys spaced a month or two apart.

For the other half of the subjects, I only showed the model the first three data points. Then, I asked it to predict how they'd answer about their health on the remaining 9 surveys.

# Accuracy

I evaluated the model's predictions in two different ways.

First, I asked, how often did the model's best guess about a patient's score turn out to be right? 

Since their are 5 possible scores, random guessing would give the right answer 20% of the time.

These ten lines show that it gets harder to make good predictions for each task as time goes on. Still, predictions for all ten tasks remain useful for well over a year.

# Absolute error

Next, I asked how close the model's 

# How sick?

The upshot of all of this is that, when ALS patients ask their doctors about planning for their futures, doctors will be able to make much more specific and accurate predictions.

# David J. Harris

