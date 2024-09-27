--百鬼夜行
local cm,m,o=GetID()
Duel.LoadScript("c666Hyakkiyakou.lua")
function cm.initial_effect(c)
	c:SetUniqueOnField(1,0,m)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	xiaoye.PendulumRepalce(c)
	xiaoye.MonsterEffectAndGrant(c,m,CATEGORY_NEGATE+CATEGORY_DESTROY,EFFECT_TYPE_QUICK_O,EVENT_CHAINING,0,0,cm.con,cm.tg,cm.op,EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return true
end
function cm.cfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp)
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=0
	local ng=Group.CreateGroup()
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te,tg=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TARGET_CARDS)
		if (te:IsHasType(EFFECT_TYPE_ACTIVATE) or te:IsActiveType(TYPE_MONSTER)) and te:GetHandlerPlayer()==1-tp and te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and tg and tg:IsExists(cm.cfilter,1,nil,tp) then
			local tc=te:GetHandler()
			a=a+1
			ng:AddCard(tc)
			if tc:IsRelateToEffect(te) then
				dg:AddCard(tc)
			end
		end
	end
	if chk==0 then return a>0 end
	Duel.SetTargetCard(dg)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,ng,ng:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te,tg=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TARGET_CARDS)
		local tc=te:GetHandler()
		if te:GetHandlerPlayer()==1-tp and (te:IsHasType(EFFECT_TYPE_ACTIVATE) or te:IsActiveType(TYPE_MONSTER)) and te:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
			and tg and tg:IsExists(cm.cfilter,1,nil,tp)
			and Duel.NegateActivation(i) and tc:IsRelateToEffect(e) and tc:IsRelateToEffect(te) then
			dg:AddCard(tc)
		end
	end
	Duel.Destroy(dg,REASON_EFFECT)
end