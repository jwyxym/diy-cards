--祭法魔女 珀
local m=21300120
local cm=_G["c"..m]
function c21300120.initial_effect(c)
	 c:EnableReviveLimit()
	 aux.AddLinkProcedure(c,cm.mfilter,2,4) 
	 local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,m)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	 local e4=e1:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCondition(cm.con)
	c:RegisterEffect(e4)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_RELEASE)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
  
end
function cm.mfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_LINK)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsType(TYPE_MONSTER) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
return e:GetHandler():GetMutualLinkedGroupCount()>0
end

function cm.activate(e,tp,eg,ep,ev,re,r,rp)
local tc=Duel.GetFirstTarget()
Duel.Release(tc,REASON_EFFECT)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
local atk=eg:GetFirst():GetBaseAttack()
local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(math.floor(atk/2))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e:GetHandler():RegisterEffect(e1)
end
function cm.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsReleasable()
end
function cm.link(c)
	if c:IsType(TYPE_LINK) then return c:GetLink() end
end
function cm.filter(c)
return c:IsReleasable() and c:IsType(TYPE_LINK) end
function cm.filter2(c,a)
return c:IsType(TYPE_LINK) and c:IsReleasable()
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
   local lg=Duel.GetMatchingGroup(cm.filter2,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return lg:CheckWithSumGreater(Card.GetLink,4) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=lg:SelectSubGroup(tp,Group.CheckWithSumEqual,false,1,4,Card.GetLink,4)
	Duel.Release(sg,REASON_COST)
	
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
   Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
   local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1,true)
end





