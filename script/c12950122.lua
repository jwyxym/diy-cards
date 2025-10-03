--[[
本lua的作者为藜奴儿，如果测试出bug请联系QQ：1502939196

未经允许不支持任何人的任何形式的修改，源数。如有需要请联系作者，而不是私自找人代为修改。
本人对于本lua的任何bug修改、源数和适配后来卡片均为免费，并且追诉期无限。

但是如果使用者私自修改了lua，不论是bug修复还是源数效果，本人对此lua都不会再提供任何形式的支持。
一旦发现任何其他人对本lua进行了任何形式的修改，本人首先自愿放弃此lua除必要署名权以外的所有权利，
同时再也会不承担对此lua的任何维护与后续适配，包括但不限于任何形式的bug修复、效果源数。

如果您想要修改此lua，可以先联系本人，本人会在第一时间进行回复。
并且我承诺，若本人在2天内没有回复您，上述注意事项可作废，您可以直接修改此lua，而后续debug与适配仍然由我来进行。

如果您对本lua有任何疑问，请联系本人，本人会在第一时间进行回复。
如果您对本lua有任何建议，请联系本人，本人会在第一时间进行处理。
]]
--刻界骑士-南十字座
local s,id,o=GetID()
function s.initial_effect(c)
	--仪式召唤限制
	c:EnableReviveLimit()
	
	--①：仪式召唤成功时回收并公开
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id+1)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	
	----Cannot target
	--local e2=Effect.CreateEffect(c)
	--e2:SetType(EFFECT_TYPE_FIELD)
	--e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	--e2:SetRange(LOCATION_MZONE)
	--e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	--e2:SetTargetRange(LOCATION_MZONE,0)
	--e2:SetCondition(s.ctcon)
	--e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x346a))
	--e2:SetValue(aux.tgoval)
	--c:RegisterEffect(e2)
	----indes
	--local e4=Effect.CreateEffect(c)
	--e4:SetType(EFFECT_TYPE_FIELD)
	--e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	--e4:SetRange(LOCATION_MZONE)
	--e4:SetTargetRange(LOCATION_MZONE,0)
	--e4:SetCondition(s.ctcon)
	--e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x346a))
	--e4:SetValue(aux.indoval)
	--c:RegisterEffect(e4)
	--disable
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetTarget(s.netg)
	e3:SetOperation(s.neop)
	c:RegisterEffect(e3)
end

function s.cfilter(c)
	return c:IsSetCard(0x346a) and c:IsType(TYPE_MONSTER) and c:IsPublic()
end
function s.ctcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_HAND,0,1,nil)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
	and not Duel.IsExistingMatchingCard(Card.IsPublic,tp,LOCATION_HAND,0,1,nil)
end
function s.thfilter(c)
	return c:IsSetCard(0x346a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,2,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			local tc=g:GetFirst()
			while tc do
				--公开到下个回合结束
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetDescription(66)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetCode(EFFECT_PUBLIC)
				e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD,2)
				tc:RegisterEffect(e1)
				tc=g:GetNext()
			end
		end
	end
end

function s.refilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
function s.netg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local pg=Duel.GetMatchingGroup(Card.IsPublic,tp,LOCATION_HAND,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.refilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.refilter,tp,0,LOCATION_ONFIELD,1,nil) and #pg>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local tg=Duel.SelectTarget(tp,s.refilter,tp,0,LOCATION_ONFIELD,1,#pg,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,#tg,0,0)
	Duel.SetChainLimit(s.chlimit(tg))
end
function s.chlimit(eg)
	return function(e,ep,tp)
		return tp==ep or eg:IsContains(e:GetHandler())
	end
end

function s.neop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetsRelateToChain()
	if #g<=0 or Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)==0
			or not g:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then return end
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
	local fid=c:GetFieldID()
	for tc in aux.Next(og) do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
	end
	og:KeepAlive()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabel(fid)
	e1:SetLabelObject(og)
	e1:SetCountLimit(1)
	e1:SetCondition(s.retcon)
	e1:SetOperation(s.retop)
	Duel.RegisterEffect(e1,tp)
end
function s.retfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabelObject():IsExists(s.retfilter,1,nil,e:GetLabel()) then
		e:GetLabelObject():DeleteGroup()
		e:Reset()
		return false
	end
	return true
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local g=e:GetLabelObject():Filter(s.retfilter,nil,fid)
	if #g<=0 then return end
	Duel.Hint(HINT_CARD,0,id)
	for p in aux.TurnPlayers() do
		local tg=g:Filter(Card.IsPreviousControler,nil,p)
		local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
		if #tg>1 and ft==1 then
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOFIELD)
			local sg=tg:Select(p,1,1,nil)
			Duel.ReturnToField(sg:GetFirst(),POS_FACEDOWN)
			tg:Sub(sg)
		end
		for tc in aux.Next(tg) do
			Duel.ReturnToField(tc)
		end
	end
	e:GetLabelObject():DeleteGroup()
end

--aux.Stringid对应提示文本:
--aux.Stringid(id,0):从墓地回收「刻界」怪兽
--aux.Stringid(id,1):攻击力上升
--aux.Stringid(id,2):回到卡组
--aux.Stringid(id,3):是否公开回收的怪兽？
