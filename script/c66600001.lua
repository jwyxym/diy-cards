--百鬼夜行 妖怪之主
local cm,m,o=GetID()
Duel.LoadScript("c666Hyakkiyakou.lua")
function cm.initial_effect(c)
	--summonlines
	local str="自古以来，人们就对妖怪心存畏惧。而走在众妖之前，领导百鬼夜行的男人，人们称其为妖怪总帅。\n亦或是如此称呼，魑魅魍魉之主，滑头鬼……"
	xiaoye.SummonLines(c,str)
	--only one card on filed
	c:SetUniqueOnField(1,0,m)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--xyz summon
	aux.AddXyzProcedure(c,nil,5,60,cm.ovfilter,aux.Stringid(m,0),60,cm.xyzop)
	c:EnableReviveLimit()
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.xyzlimit)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(cm.con)
	e1:SetTarget(cm.tg)
	e1:SetOperation(cm.op)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,3))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,m)
	e2:SetCondition(cm.con2)
	e2:SetCost(xiaoye.MonsterEffectCost)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,2))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetTarget(cm.tg1)
	e3:SetOperation(cm.op1)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m,2))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(cm.con1)
	e4:SetTarget(cm.tg1)
	e4:SetOperation(cm.op1)
	c:RegisterEffect(e4)
end
function cm.ovfilter(c)
	return c:IsFaceup() and c:IsCode(m+1)
end
function cm.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,m)==0 end
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function cm.filter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x5660) and c:IsCanOverlay()
end
function cm.filter0(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x5660) and c:IsCanOverlay() and c:IsFaceup()
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_DECK,0,1,nil) end
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g then
			Duel.Overlay(e:GetHandler(),g)
			if Duel.IsExistingMatchingCard(cm.filter0,tp,LOCATION_EXTRA,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
				local sg=Duel.SelectMatchingCard(tp,cm.filter0,tp,LOCATION_EXTRA,0,1,1,nil)
				Duel.Overlay(e:GetHandler(),sg)
			end
		end
	end
end
function cm.con1(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function cm.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,6) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:GetFlagEffect(m)==0 end
	c:RegisterFlagEffect(m,RESET_CHAIN,0,1)
end
function cm.filter1(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x5660) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if not Duel.IsPlayerCanDiscardDeck(tp,6) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.ConfirmDecktop(tp,6)
	local g=Duel.GetDecktopGroup(tp,6)
	if g:GetCount()>0 then
		if g:IsExists(cm.filter1,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local sc=g:FilterSelect(tp,cm.filter1,1,1,nil):GetFirst()
			if not Duel.Equip(tp,sc,c) then return end
			--equip limit
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetLabelObject(c)
			e1:SetValue(cm.eqlimit)
			sc:RegisterEffect(e1)
		end
		Duel.ShuffleDeck(tp)
	end
end
function cm.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function cm.con2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,66600026) then return Duel.GetCurrentChain()>=2 end
	return Duel.GetCurrentChain()>=4
end
function cm.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=0
	local ng=Group.CreateGroup()
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		if (te:IsHasType(EFFECT_TYPE_ACTIVATE) or te:IsActiveType(TYPE_MONSTER)) and te:GetHandlerPlayer()==1-tp then
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
function cm.op2(e,tp,eg,ep,ev,re,r,rp)
	local ran=Duel.GetMatchingGroup(nil,tp,LOCATION_ALL,LOCATION_ALL,nil):RandomSelect(tp,1):GetFirst()
	local a=0
	if ran then a=ran:GetSequence()%2 end
	if a>0 then
	Debug.Message("告诉这世上的妖怪们，我要成为魑魅魍魉之主。\n哪怕那是条修罗之路，我也绝不让步。")
	else
	Debug.Message("不管是人类还是妖怪，我将背负一切。\n所有妖怪都在我身后，跟上我的百鬼夜行吧。")
	end
	for i=66600020,66600025 do
	Duel.Hint(HINT_CARD,0,i)
	end
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local tc=te:GetHandler()
		if te:GetHandlerPlayer()==1-tp and (te:IsHasType(EFFECT_TYPE_ACTIVATE) or te:IsActiveType(TYPE_MONSTER))
			and Duel.NegateActivation(i) and tc:IsRelateToEffect(e) and tc:IsRelateToEffect(te) then
			dg:AddCard(tc)
		end
	end
	Duel.Destroy(dg,REASON_EFFECT)
end