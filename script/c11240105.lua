-- 七代码 角色扮演兽
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_SEND_REPLACE)
	e3:SetRange(LOCATION_HAND+LOCATION_ONFIELD)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_HAND+LOCATION_ONFIELD)
	e4:SetTarget(s.reptg2)
	e4:SetValue(s.repval2)
	e4:SetOperation(s.repop2)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_XMATERIAL)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(1200)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_XMATERIAL)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetCondition(s.immcon)
	e6:SetValue(s.efilter)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_XMATERIAL)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EFFECT_IMMUNE_EFFECT)
	e8:SetCondition(s.immcon)
	e8:SetValue(s.efilter)
	local e9=Effect.CreateEffect(c)
	e9:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCode(EFFECT_PIERCE)
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e10:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e10:SetRange(LOCATION_SZONE)
	e10:SetTargetRange(LOCATION_MZONE,0)
	e10:SetTarget(s.eftg)
	e10:SetLabelObject(e8)
	c:RegisterEffect(e10)
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e11:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e11:SetRange(LOCATION_SZONE)
	e11:SetTargetRange(LOCATION_MZONE,0)
	e11:SetTarget(s.eftg)
	e11:SetLabelObject(e9)
	c:RegisterEffect(e11)
end
function s.rlfilter(c,tp)
  local re=Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_RELEASE)
  local val=nil
  if re then val=re:GetValue() end
  return (c:IsReleasable(REASON_EFFECT) or (c:IsType(TYPE_SPELL+TYPE_TRAP) and (val==nil or val(re,c)~=true))) and c:IsSetCard(0x6c1) 
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.rlfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) and Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
  local g=Duel.SelectMatchingCard(tp,s.rlfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	Duel.HintSelection(g)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT+REASON_RELEASE)~=0 then
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_ONFIELD) or c:IsFacedown() then return end
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and rp~=tp and eg:IsExists(s.repfilter,1,nil,e,tp) and c:IsReleasable(REASON_EFFECT) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
		e:SetLabelObject(c)
		return true
	end
end
function s.repfilter(c,e,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c~=e:GetHandler() and c:IsSetCard(0xb94) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.repval(e,c)
	return s.repfilter(c,e,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	e:SetLabelObject(nil)
	if c then
		Duel.Release(c,REASON_EFFECT+REASON_REPLACE)
	end
end
function s.reptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and eg:IsExists(s.repfilter2,1,nil,e,tp) and c:IsReleasable(REASON_EFFECT) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repfilter2(c,e,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c~=e:GetHandler() and c:IsSetCard(0xb94) and c:IsReason(REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
function s.repval2(e,c)
	return s.repfilter2(c,e,e:GetHandlerPlayer())
end
function s.repop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,0,id)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
	Duel.Release(c,REASON_EFFECT+REASON_REPLACE)
end
function s.immcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
function s.eftg(e,c)
	return c:IsOriginalCodeRule(11240120) or c:IsOriginalCodeRule(11240125)
end