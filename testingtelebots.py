#!/usr/bin/env python
# -*- coding: utf-8 -*-
# This program is dedicated to the public domain under the CC0 license.

"""
Basic example for a bot that uses inline keyboards.
"""
import logging
import telegram
from telegram import InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Updater, CommandHandler, CallbackQueryHandler

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)
logger = logging.getLogger(__name__)
bot = telegram.Bot(token = "1000442743:AAGjEMXi7HOhDygLZkZKQG4PmQU6lN1i0uc")


def start(update, context):
    username = update.message.from_user
    print(username)
    keyboard = [[InlineKeyboardButton("Option 1", callback_data='1'),
                 InlineKeyboardButton("Option 2", callback_data='2')],

                [InlineKeyboardButton("Option 3", callback_data='3')]]

    reply_markup = InlineKeyboardMarkup(keyboard)

    update.message.reply_text('Please choose:', reply_markup=reply_markup)


def button(update, context):
    # print(1111111111111111111111111111111111)
    # print(update['from']['id'])
    # # print(update)
    # print(222222222222222222222222222222)
    # print(context)
    query = update.callback_query
    print(1111111111111111111111111111111111)
    print(query.data)

    keyboard = [[InlineKeyboardButton("Optdsdsaion 1", callback_data='1'),
                 InlineKeyboardButton("Optdsadsadion 2", callback_data='2')],

                [InlineKeyboardButton("dsadsadsa 3", callback_data='3')]]

    reply_markup = InlineKeyboardMarkup(keyboard)
    name = update['_effective_user']['id']
    query.edit_message_text(text="Selected option: {}, selected by {}".format(query.data,name))
    print(update)
    chat_id = update['_effective_message']['chat']['id']
    print(chat_id)
    bot.send_message(chat_id = chat_id ,text="A two column menu", reply_markup=reply_markup)


def help(update, context):
    update.message.reply_text("Use /start to test this bot.")


def error(update, context):
    """Log Errors caused by Updates."""
    logger.warning('Update "%s" caused error "%s"', update, context.error)


def main():
    # Create the Updater and pass it your bot's token.
    # Make sure to set use_context=True to use the new context based callbacks
    # Post version 12 this will no longer be necessary
    updater = Updater(
        "1000442743:AAGjEMXi7HOhDygLZkZKQG4PmQU6lN1i0uc", use_context=True)

    updater.dispatcher.add_handler(CommandHandler('start', start))
    updater.dispatcher.add_handler(CallbackQueryHandler(button))
    updater.dispatcher.add_handler(CommandHandler('help', help))
    updater.dispatcher.add_error_handler(error)

    # Start the Bot
    updater.start_polling()

    # Run the bot until the user presses Ctrl-C or the process receives SIGINT,
    # SIGTERM or SIGABRT
    updater.idle()


if __name__ == '__main__':
    main()

