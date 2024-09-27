--百鬼夜行
local cm,m,o=GetID()
Duel.LoadScript("c666Hyakkiyakou.lua")
function cm.initial_effect(c)
	c:SetUniqueOnField(1,0,m)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	xiaoye.PendulumRepalce(c)
	xiaoye.MonsterEffectAndGrant(c,m,CATEGORY_TODECK,EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O,EVENT_TO_HAND,0,0,cm.con,cm.tg,cm.op,0)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW
end
function cm.filter(c,tp)
	return c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_DECK) and c:IsAbleToDeck()
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(cm.filter,nil,tp)
	if chk==0 then return g:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(cm.filter,nil,tp)
	if g:GetCount()>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end