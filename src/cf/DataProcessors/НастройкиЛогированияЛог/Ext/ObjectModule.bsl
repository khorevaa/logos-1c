﻿
Перем мПрочитанныеНастройкиЛоггеров;
Перем мПрочитанныеСпособыВывода;
Перем мНастройкиЛогирования;
Перем ОбратнаяКартаУровней;

Процедура ПрочитатьИзКонфигурации() Экспорт
	
	СтрокаНастройкиЛогирования = ХранилищеОбщихНастроек.Загрузить(КлючНастройкиХранилища());
	Если СтрокаНастройкиЛогирования = Неопределено Тогда
		Попытка
			УстановитьПривилегированныйРежим(Истина);
			СтрокаНастройкиЛогирования = ХранилищеОбщихНастроек.Загрузить(КлючНастройкиХранилища(), , , ИмяОбщегоВиртуальногоПользователя());
		Исключение
		КонецПопытки;
	КонецЕсли;
	
	Если СтрокаНастройкиЛогирования <> Неопределено Тогда
		
		//ПрочитатьИзСтроки(СтрокаНастройкиЛогирования);
		ПрочитатьКонфигурацию(СтрокаНастройкиЛогирования);

	КонецЕсли;

КонецПроцедуры

Процедура ЗаписатьВКонфигурацию(Знач ИмяЛога, Знач Уровень, Знач ДопПараметры = "", Знач ОбщиеНастройки = Ложь) Экспорт
	Если Не ЗначениеЗаполнено(ДопПараметры) Тогда
		ДопПараметры = ОбратнаяКартаУровней[Уровень];
	КонецЕсли;
	Строка = СтрШаблон("logger.%1=%2", ИмяЛога, ДопПараметры);
	
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.УстановитьТекст(Строка);

	Если ОбщиеНастройки Тогда
		//УстановитьПривилегированныйРежим(Истина);
		ХранилищеОбщихНастроек.Сохранить(КлючНастройкиХранилища(), , ТекстовыйДокумент, , ИмяОбщегоВиртуальногоПользователя());
	Иначе
		ХранилищеОбщихНастроек.Сохранить(КлючНастройкиХранилища(), , ТекстовыйДокумент);
	КонецЕсли;
КонецПроцедуры

// Читает настройки из конфигурационного файла
//
Процедура Прочитать(Знач ИмяФайла) Экспорт
	
	Документ = Новый ТекстовыйДокумент;
	Документ.Прочитать(ИмяФайла);
	ПрочитатьКонфигурацию(Документ);

КонецПроцедуры // Прочитать(Знач ИмяФайла)

Процедура ПрочитатьИзСтроки(Знач Строка) Экспорт
	Документ = Новый ТекстовыйДокумент;
	Документ.УстановитьТекст(Строка);
	ПрочитатьКонфигурацию(Документ);
КонецПроцедуры

Процедура ПрочитатьКонфигурацию(Знач Документ)
	мПрочитанныеСпособыВывода = Новый Соответствие;
	мПрочитанныеНастройкиЛоггеров = Новый Соответствие;

	Для Сч = 1 По Документ.КоличествоСтрок() Цикл
		СтрокаНастроек = Документ.ПолучитьСтроку(Сч);

		ОбработатьСтрокуНастроек(СтрокаНастроек);

	КонецЦикла;

	СоздатьОбъектыНастроек();

КонецПроцедуры

// Получает опции по которым будет настроен логгер
//
Функция Получить(Знач ИмяЛоггера) Экспорт
	
	Если мНастройкиЛогирования = Неопределено Тогда
		Возврат Неопределено;
	Иначе
		Возврат мНастройкиЛогирования[ИмяЛоггера];
	КонецЕсли;

КонецФункции

Процедура ОбработатьСтрокуНастроек(Знач СтрокаНастроек)
	
	Если Лев(СтрокаНастроек,1) = "#" Или ПустаяСтрока(СтрокаНастроек) Тогда
		// комментарий
		Возврат;
	КонецЕсли;

	Поз = Найти(СтрокаНастроек, "=");
	Если Поз = 0 Тогда
		ВызватьИсключение "Неверный формат строки настроек: " + СтрокаНастроек;
	КонецЕсли;

	Ключ     = Лев(СтрокаНастроек, Поз-1);
	Значение = Сред(СтрокаНастроек, Поз+1);
	
	КлассНастроек = ОчереднойФрагмент(Ключ);
	
	Если ПустаяСтрока(Ключ) Тогда
		ВызватьИсключение "Неверная строка настроек, нет опций у класса: " + КлассНастроек;
	КонецЕсли;

	ОбработатьКлассНастроек(КлассНастроек, Ключ, Значение);

КонецПроцедуры

Процедура СоздатьОбъектыНастроек() 
	
	мНастройкиЛогирования = Новый Соответствие;
	КартаУровней = СоздатьКартуУровней();
	//КартаУровней = Новый Соответствие;
	//КартаУровней.Вставить("DEBUG", УровниЛога.Отладка);
	//КартаУровней.Вставить("INFO", УровниЛога.Информация);
	//КартаУровней.Вставить("WARN", УровниЛога.Предупреждение);
	//КартаУровней.Вставить("ERROR", УровниЛога.Ошибка);
	//КартаУровней.Вставить("CRITICALERROR", УровниЛога.КритичнаяОшибка);
	//КартаУровней.Вставить("DISABLE", УровниЛога.Отключить);

	Для каждого ОбъявленныйЛоггер Из мПрочитанныеНастройкиЛоггеров Цикл
		
		Настройка = Новый Структура;
		Настройка.Вставить("Уровень", КартаУровней[ОбъявленныйЛоггер.Значение.Уровень]);
		Настройка.Вставить("СпособыВывода", Новый Соответствие);

		Для Каждого ПривязанныйСпособВывода Из ОбъявленныйЛоггер.Значение.Аппендеры Цикл
			Аппендер = мПрочитанныеСпособыВывода[ПривязанныйСпособВывода];
			Если Аппендер = Неопределено Тогда
				ВызватьИсключение СтрШаблон("К логу {%1} привязан способ вывода {%2}, но этот способ нигде не описан",
					ОбъявленныйЛоггер.Ключ,
					ПривязанныйСпособВывода);
			КонецЕсли;

			Настройка.СпособыВывода.Вставить(ПривязанныйСпособВывода, Аппендер);

		КонецЦикла;

		мНастройкиЛогирования.Вставить(ОбъявленныйЛоггер.Ключ, Настройка);

	КонецЦикла;

КонецПроцедуры

Функция ОчереднойФрагмент(Ключ, Разделитель=".")
	Поз = Найти(Ключ, Разделитель);
	Если Поз > 0 Тогда
		Ответ = Лев(Ключ, Поз-1);
		Ключ = Сред(Ключ, Поз+1);
	Иначе
		Ответ = Ключ;
		Ключ = "";
	КонецЕсли;

	Возврат Ответ;
КонецФункции // ОчереднойФрагмент(Ключ)

Процедура ОбработатьКлассНастроек(Знач КлассНастроек, Знач Ключ, Знач Значение)
	
	Если КлассНастроек = "logger" Тогда
		ОбработатьНастройкуЛоггера(Ключ, Значение);
	ИначеЕсли КлассНастроек = "appender" Тогда
		ОбработатьНастройкуСпособаВывода(Ключ, Значение);
	Иначе
		ВызватьИсключение "Неизвестный класс настроек: " + КлассНастроек;
	КонецЕсли

КонецПроцедуры

Процедура ОбработатьНастройкуЛоггера(Знач Ключ, Знач Значение)
	
	ПрочитаннаяНастройка = Новый Структура;
	ПрочитаннаяНастройка.Вставить("Уровень");
	ПрочитаннаяНастройка.Вставить("Аппендеры");
	мПрочитанныеНастройкиЛоггеров.Вставить(Ключ, ПрочитаннаяНастройка);

	ПрочитаннаяНастройка.Уровень = СокрЛП(ОчереднойФрагмент(Значение, ","));
	Если Не ИзвестныйУровеньЛога(ПрочитаннаяНастройка.Уровень) Тогда
		ВызватьИсключение "Неизвестный уровень лога: " + ПрочитаннаяНастройка.Уровень;
	КонецЕсли;

	ПрочитаннаяНастройка.Аппендеры = Новый Массив;
	Пока Не ПустаяСтрока(Значение) Цикл
		Аппендер = СокрЛП(ОчереднойФрагмент(Значение, ","));
		Если Не ПустаяСтрока(Аппендер) Тогда
			ПрочитаннаяНастройка.Аппендеры.Добавить(Аппендер);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

Процедура ОбработатьНастройкуСпособаВывода(Знач Ключ, Знач Значение)
	
	ИмяАппендера = ОчереднойФрагмент(Ключ);
	Если ПустаяСтрока(Ключ) Тогда
		// это объявление аппендера, обязательный элемент
		ОписаниеАппендера = Новый Структура;
		ОписаниеАппендера.Вставить("Класс", Значение);
		ОписаниеАппендера.Вставить("Свойства", Новый Соответствие);
		мПрочитанныеСпособыВывода[ИмяАппендера] = ОписаниеАппендера;
	Иначе
		// это свойство аппендера, сам аппендер обязан быть описан ранее
		НастройкаАппендера = мПрочитанныеСпособыВывода[ИмяАппендера];
		Если НастройкаАппендера = Неопределено Тогда
			ВызватьИсключение СтрШаблон("Неверная структура файла. Класс способа вывода {%1} должен быть описан ранее строки {%2}",
				ИмяАппендера,
				ИмяАппендера + "." + Ключ);
		КонецЕсли;
		НастройкаАппендера.Свойства.Вставить(Ключ, Значение);
	КонецЕсли;

КонецПроцедуры

Функция ИзвестныйУровеньЛога(Знач ИмяУровня)
	
	ДопустимыеУровни = "DEFAULT,DEBUG,INFO,WARN,ERROR,CRITICALERROR,DISABLE,";
	Возврат Найти(ДопустимыеУровни, ИмяУровня+",") > 0;

КонецФункции

Функция КлючНастройкиХранилища()
	Возврат "НастройкиЛогированияЛог";
КонецФункции

Функция ИмяОбщегоВиртуальногоПользователя()
	Возврат "НастройкиЛогированияЛог";
КонецФункции

Функция СоздатьКартуУровней()
	КартаУровней = Новый Соответствие;
	КартаУровней.Вставить("DEBUG", УровниЛога.Отладка);
	КартаУровней.Вставить("INFO", УровниЛога.Информация);
	КартаУровней.Вставить("WARN", УровниЛога.Предупреждение);
	КартаУровней.Вставить("ERROR", УровниЛога.Ошибка);
	КартаУровней.Вставить("CRITICALERROR", УровниЛога.КритичнаяОшибка);
	КартаУровней.Вставить("DISABLE", УровниЛога.Отключить);
	Возврат КартаУровней;
КонецФункции

Функция СоздатьОбратнуюКартуУровней()
	 
	Если Не ЗначениеЗаполнено(ОбратнаяКартаУровней) Тогда
		Карта = Новый Соответствие;
		КартаУровней = СоздатьКартуУровней();
		Для Каждого КлючЗначение Из КартаУровней Цикл
			Карта.Вставить(КлючЗначение.Значение, КлючЗначение.Ключ);
		КонецЦикла;
		
		ОбратнаяКартаУровней = Новый ФиксированноеСоответствие(Карта);
	КонецЕсли;
	
	Возврат ОбратнаяКартаУровней;
КонецФункции


Процедура ЗаполнитьУровниЛога()
	Если Не ЗначениеЗаполнено(УровниЛога) Тогда
		УровниЛога = Новый Структура;
		УровниЛога.Вставить("Отладка"        , 0);
		УровниЛога.Вставить("Информация"     , 1);
		УровниЛога.Вставить("Предупреждение" , 2);
		УровниЛога.Вставить("Ошибка"         , 3);
		УровниЛога.Вставить("КритичнаяОшибка", 4);
		УровниЛога.Вставить("Отключить"      , 5);
		
		УровниЛога = Новый ФиксированнаяСтруктура(УровниЛога);
	КонецЕсли;
КонецПроцедуры

ЗаполнитьУровниЛога();
СоздатьОбратнуюКартуУровней();