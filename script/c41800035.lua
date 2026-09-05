--麻花卷猫☆味美喵
--[[
本lua的作者为藜奴儿，如果测试出bug请联系QQ：1502939196

未经允许不支持任何人的任何形式的修改，源数。如有需要请联系作者，而不是私自找人代为修改。
本人对于本lua的任何bug修改、源数和适配后来卡片均为免费，并且追诉期无限。

但是如果使用者私自修改了lua，不论是bug修复还是效果源数，本人对此lua都不会再提供任何形式的支持。
一旦发现任何其他人对本lua进行了任何形式的修改，本人首先自愿放弃此lua除必要署名权以外的所有权利，
同时再也会不承担对此lua的任何维护与后续适配，包括但不限于任何形式的bug修复、效果源数。

如果您想要修改此lua，可以先联系本人，本人会在第一时间进行回复。
并且我承诺，若本人在2天内没有回复您，上述注意事项可作废，您可以直接修改此lua，而后续debug与适配仍然由我来进行。

如果您对本lua有任何疑问，请联系本人，本人会在第一时间进行回复。
如果您对本lua有任何建议，请联系本人，本人会在第一时间进行处理。
]]

local s,id=GetID()
function s.initial_effect(c)
	--①效果：特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--②效果：特殊召唤成功时特殊召唤墓地/除外怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(s.checkop)
	c:RegisterEffect(e4)

end
--①效果
function s.chkfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	if #g==0 then return true end
	return  g:FilterCount(s.chkfilter,nil)==#g
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--②效果
function s.spfilter(c,e,tp)
	return (c:IsLink(1) or (c:IsType(TYPE_SYNCHRO) and c:IsLevel(2))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rmfilter(c)
	return (c:IsLink(1) or (c:IsType(TYPE_SYNCHRO) and c:IsLevel(2))) and c:IsAbleToExtra()
end
function s.bothfilter(c,e,tp)
	return (c:IsLink(1) or (c:IsType(TYPE_SYNCHRO) and c:IsLevel(2))) and (c:IsAbleToExtra()or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local chko=nil
	if e:GetHandler():GetFlagEffect(id)>0 then
		chko=s.bothfilter
	else
		chko=s.spfilter
	end
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chko(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(chko,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	if e:GetHandler():GetFlagEffect(id)>0 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,chko,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc)) then return end
	local b1=tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local b2=e:GetLabel()==1 and tc:IsAbleToExtra() and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if b1 and (not b2 or not Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	elseif b2 then
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	if re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsType(TYPE_SYNCHRO) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TEMP_REMOVE,0,1)
	end
end
