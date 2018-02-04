# Predicting ALS symptom progression

Hi, I'm Dave Harris, and I'll be telling you about my work on using forcasting the progression of Lou Gehrig's disease, which is a neurodegenerative disease causing paralysis. 

It's a lot more common than many people realize: the lifetime risk is about 1 in 400 people.

# It's hard

For many patients, one of the most difficult aspects of the disease is the uncertainty: patients want to know how long they have until they'll need a wheelchair or until they won't be able to speak, and doctors basically can't give accurate answers yet.

# Famous folks

Just to give a sense of how variable this disease is, here are two of the most famous people with the disease. Lou Gehrig lived less than two years after he was diagnosed, while Stephen Hawking is still alive more than 50 years later. There's a lot of research on classifying subtypes of the disease, but it's still hard to say where a given patient will fall on this spectrum.

# How sick will I be next year?

To try and address this, I downloaded a collection of patient histories from the PRO-ACT database. I'll be focusing on this "functional rating scale", which describes patients' ability to perform 10 basic tasks.

Each time someone takes this test, they report their ability to perform these tasks on a scale from 4 (which indicates full function) to zero (which indicates no function). 

For example, if the task is Walking, then "4" is normal walking, "2" is walking with a cane, and "0" is when you can't move your legs at all.

# How do we use this for prediction?

Okay, so we get ten of these time series for each patient, but how do we use them for prediction? There's a lot of structure here, since we're trying to make 10 different kinds of predictions for each patient over time. It's not really clear how we'd squeeze all of this into something like a random forest.

# Logistic regression / ordered logit

# App

The app lets the doctor can pull up a dashboard for each patient.  

Here is some demographic and medical information.

Below, predicted scores over the next two years are grouped by type: respiratory, bulbar (which means mouth and throat), and motor tasks involving the arms and legs. At a glance, the doctor can see that the patient can expect to lose additional motor function, but that they'll probably continue eating and breathing okay.

Now let's say the patient wants to know if they'll need a wheelchair one year from now. Clicking the "walking" task brings up their likely scores. This area marked "two" corresponds to walking with assistance, so that's the most likely scenario, but they could still lose that ability at any time.  

The doctor can also move their mouse to see the patient's projected scores at different points in the future.

# Model validation

Finally, we should make sure that the model's predictions are actually worth something.  

# The prediction task

To do this, I set up a prediction task. Here, time is the x-axis.

First, I showed the model the complete histories from a few hundred subjects, which included 12 surveys spaced a month or two apart.

Next, I showed the model the first three data points for the other half of the subjects, and asked it to predict how they'd answer about their health on the remaining 9 surveys.

# Accuracy

I evaluated the model's performance in two different ways.

First, I asked, how often did subjects respond to their survey with the highest-probability score?