class StatisticsController < ApplicationController
	def index
		@date = Statistic.first || Statistic.create

		begin_day = Date.today
		end_day = Date.today
		@date.update(start_date: begin_day, end_date: end_day)
	end

	def search
		@date = Statistic.first
		@date.update(date_params)

		unless @date.start_date <= @date.end_date
			flash.now[:alert] = "There was a problem with date"
			begin_day = Date.today
			end_day = Date.today
			@date.update(start_date: begin_day, end_date: end_day)
		end

		render "statistics/index"
	end

	private

	def date_params
		params.require(:statistic).permit(:start_date, :end_date)
	end
end