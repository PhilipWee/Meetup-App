from telegram import InlineKeyboardButton, InlineKeyboardMarkup, ReplyKeyboardRemove, KeyboardButton, ReplyMarkup, ReplyKeyboardMarkup, ForceReply, base
from telegram.ext import Updater, CommandHandler, CallbackQueryHandler, ConversationHandler, MessageHandler, Filters
import logging

# Enable logging
logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',level=logging.INFO)
logger = logging.getLogger(__name__)

FIRST, SECOND, THIRD, FOURTH, FIFTH, SIXTH = range(6)


def start(bot, update):
    keyboard = [[InlineKeyboardButton(u"Let's Go!", callback_data=str(FIRST))]]
    print(bot)
    update.message.reply_text(u"Squeak! Hello I am MeetupMouse Bot! Lets organize your meeting! /cancel at anytime to stop!",reply_markup=InlineKeyboardMarkup(keyboard))
    return 'nuvndiuvndsuvnds'

def first(bot, update):
    query = update.callback_query
    print(bot)
    print(update)
    keyboard = [
        [InlineKeyboardButton(u"Recreation", callback_data=str(SECOND))],
        [InlineKeyboardButton(u"Food", callback_data=str(SECOND))],
        [InlineKeyboardButton(u"Project", callback_data=str(SECOND))]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    bot.edit_message_text(chat_id=query.message.chat_id, message_id=query.message.message_id, text=u"Please choose your meeting type")
    bot.edit_message_reply_markup(chat_id=query.message.chat_id, message_id=query.message.message_id, reply_markup=reply_markup)
    return SECOND

def second(bot, update):
    query = update.callback_query
    transport_keyboard = [
        [InlineKeyboardButton("Driving", callback_data='Driving')],
        [InlineKeyboardButton("Public Transit", callback_data='Public')],
        [InlineKeyboardButton("Walk", callback_data='Walk')]
        ]

    transport_reply_markup = InlineKeyboardMarkup(transport_keyboard)
    bot.edit_message_text(chat_id=query.message.chat_id, message_id=query.message.message_id, text=u"How would you be travelling there?")
    bot.edit_message_reply_markup(chat_id=query.message.chat_id, message_id=query.message.message_id ,reply_markup=transport_reply_markup)
    return THIRD

def third(bot, update):
    query = update.callback_query
    speed_keyboard = [
        [InlineKeyboardButton("ASAP!", callback_data='speed3')],
        [InlineKeyboardButton("No rush, but not too long!", callback_data='speed2')],
        [InlineKeyboardButton("I anything wan", callback_data='speed1')]
        ]

    speed_reply_markup = InlineKeyboardMarkup(speed_keyboard)
    bot.edit_message_text(chat_id=query.message.chat_id, message_id=query.message.message_id, text=u"How fast would you like to get there?")
    bot.edit_message_reply_markup(chat_id=query.message.chat_id, message_id=query.message.message_id, reply_markup=speed_reply_markup)
    return FOURTH

def fourth(bot, update):
    query = update.callback_query
    ratings_keyboard = [
        [InlineKeyboardButton("Delight me", callback_data='ratings3')],
        [InlineKeyboardButton("Nothing too shit", callback_data='ratings2')],
        [InlineKeyboardButton("I anything wan", callback_data='ratings1')]
        ]
    ratings_reply_markup = InlineKeyboardMarkup(ratings_keyboard)
    bot.edit_message_text(chat_id=query.message.chat_id, message_id=query.message.message_id, text=u"How do you like your food?")
    bot.edit_message_reply_markup(chat_id=query.message.chat_id, message_id=query.message.message_id, reply_markup=ratings_reply_markup)
    return FIFTH

def fifth(bot, update):
    query = update.callback_query
    bot.edit_message_text(chat_id=query.message.chat_id, message_id=query.message.message_id, text=u"Great! Now reply with your location!")
    return SIXTH

def sixth(bot, update):
    user = update.message.from_user
    user_location = update.message.location
    logger.info("Location of %s: %f / %f", user.first_name, user_location.latitude,user_location.longitude)
    update.message.reply_text('Thanks! Now I have stolen all your data u slut')
    return



def cancel(bot, update):
    update.message.reply_text('Squeak squeak! Catch you another time!.', reply_markup=ReplyKeyboardRemove())
    return ConversationHandler.END


# conv_handler = ConversationHandler(
#     entry_points=[CommandHandler('start', start)],
#     states={
#         FIRST: [CallbackQueryHandler(first)],
#         SECOND: [CallbackQueryHandler(second)],
#         THIRD: [CallbackQueryHandler(third)],
#         FOURTH: [CallbackQueryHandler(fourth)],
#         FIFTH: [CallbackQueryHandler(fifth)],
#         SIXTH: [CallbackQueryHandler(sixth), MessageHandler(Filters.location, sixth)],
#     },
#     fallbacks=[CommandHandler('cancel', cancel)]
# )

# updater.dispatcher.add_handler(conv_handler)
# updater.start_polling()
# updater.idle()


def main():
    updater = Updater("1000442743:AAGjEMXi7HOhDygLZkZKQG4PmQU6lN1i0uc")
    updater.dispatcher.add_handler(CommandHandler('start', start))
    updater.dispatcher.add_handler(CallbackQueryHandler(first))
    updater.dispatcher.add_handler(CallbackQueryHandler(second))
    updater.dispatcher.add_handler(CallbackQueryHandler(third))
    updater.dispatcher.add_handler(CallbackQueryHandler(fourth))
    updater.dispatcher.add_handler(CallbackQueryHandler(fifth))
    updater.dispatcher.add_handler(CallbackQueryHandler(sixth)), MessageHandler(Filters.location, sixth)
    updater.start_polling()
    updater.idle()

if __name__ == "__main__":
    main()