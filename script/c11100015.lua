--铁机龙战神·三形武装
local m=11100015
local cm=_G["c"..m]
function c11100015.initial_effect(c)
  
	--link summon
	c:EnableReviveLimit()
   aux.AddLinkProcedure(c,nil,2,4,cm.lcheck)
 local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,m)
	e2:SetCondition(cm.discon)
	e2:SetTarget(cm.distg)
	e2:SetOperation(cm.disop)
	c:RegisterEffect(e2)
local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,m+1000)
	e4:SetCondition(cm.spcon2)
	e4:SetOperation(cm.spop)
	c:RegisterEffect(e4)
 local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetOperation(cm.thop)
	c:RegisterEffect(e3)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
Debug.Message("炎铠·霜翼·源核，此乃改变战局的力量！如今三者合而为一！能量共鸣，灵魂联通！连接召唤，降临吧！")
Debug.Message("Link 4 ，铁机龙战神·三形武装！")
end
function cm.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) 
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local aa=Duel.SelectMatchingCard(tp,cm.filter1,tp,LOCATION_GRAVE,0,1,4,nil)
Duel.Remove(aa,POS_FACEUP,REASON_EFFECT)
local bb=Duel.SelectMatchingCard(tp,cm.filter3,tp,LOCATION_GRAVE,0,1,1,nil)
Duel.SpecialSummon(bb,0,tp,tp,false,false,POS_FACEUP)
local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(cm.atkval)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			bb:GetFirst():RegisterEffect(e1)
			
 local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetTargetRange(1,0)
	e2:SetTarget(cm.splimit2)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function cm.atkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa60)
end
function cm.atkval(e,c)
	return Duel.GetMatchingGroupCount(cm.atkfilter,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil)*300
end
function cm.splimit2(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xa60)
end
function cm.filter1(c)
return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa60) end
function cm.filter3(c)
return c:IsType(TYPE_LINK) and c:IsSetCard(0xa60) end
function cm.discon(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
 local lg=c:GetLinkedGroup()
if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev) and lg:IsExists(cm.filter1,2,nil)
end
function cm.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function cm.disop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local lg=c:GetLinkedGroup()
local la=lg:Select(tp,1,1,nil):GetFirst()
 Duel.Destroy(la,REASON_EFFECT)
end
function cm.lcheck(g,lc)
	return g:IsExists(cm.matfilter,1,nil)
end
function cm.matfilter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_LINK)


end