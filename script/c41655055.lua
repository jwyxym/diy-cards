-- 烬雪的坚韧·格洛克
local s,id,o=GetID()
function s.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c,false)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,6,2)
	--lv change
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_XYZ_LEVEL)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(s.lvtg)
	e0:SetValue(s.lvval)
	c:RegisterEffect(e0)
	--move
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	s.jinxue_effect=e1
	--splimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	--to deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,10))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
s.pendulum_level=7
function s.matfilter(c)
	return c:IsFusionSetCard(0xe93) or c:IsFusionType(TYPE_NORMAL)
end
function s.lvtg(e,c)
	return c:IsLevelAbove(1) and c:IsType(TYPE_NORMAL)
end
function s.lvval(e,c,rc)
	local lv=c:GetLevel()
	if rc==e:GetHandler() then return 6
	else return lv end
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_MZONE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=g:Select(1-tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.SendtoGrave(sg,REASON_RULE,1-tp)
	end
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xe93) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.tdfilter2(c)
	return c:IsSetCard(0xe93) and c:IsAbleToDeck()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
	local b2=Duel.IsExistingMatchingCard(s.tdfilter2,tp,LOCATION_HAND,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	if op==1 then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.tdfilter2,tp,LOCATION_HAND,0,1,1,nil)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end	
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
