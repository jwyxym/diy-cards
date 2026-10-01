-- 蓝堇色彩之影
local s,id,o=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xe96),1,true)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.hspcon)
	e2:SetTarget(s.hsptg)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2)
	--①-1 对方蓝堇卡离场改为除外
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e3:SetTargetRange(0,LOCATION_ONFIELD)
	e3:SetTarget(s.retg)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)
	--①-2 不受对方蓝堇卡效果影响
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	--②-1 特殊召唤成功时
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetTarget(s.rmtg)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)
	--②-2 攻击宣言时
	local e6=e5:Clone()
	e6:SetCode(EVENT_ATTACK_ANNOUNCE)
	c:RegisterEffect(e6)
	--②-3 成为对方发动的效果对象时
	local e7=e5:Clone()
	e7:SetCode(EVENT_BE_EFFECT_TARGET)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCondition(s.objcon)
	c:RegisterEffect(e7)
end
function s.hspfilter(c,tp,sc)
	return c:IsFusionSetCard(0xe96) and c:IsStatus(STATUS_SUMMON_TURN+STATUS_SPSUMMON_TURN) and c:IsControler(tp) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
		and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
function s.hspcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroupEx(c:GetControler(),s.hspfilter,1,REASON_SPSUMMON,false,nil,c:GetControler(),c)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(s.hspfilter,nil,tp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	Duel.Release(tc,REASON_SPSUMMON)
end
function s.retg(e,c)
	return c:IsSetCard(0xe96)
end
-- 免疫判断：对方发动的蓝堇卡效果
function s.efilter(e,te)
	return te:GetHandler():IsSetCard(0xe96) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
-- ②-3 条件：成为对方发动的效果对象
function s.objcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsContains(e:GetHandler())
end
-- ② 共通目标与操作
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end
function s.codefilter(c,code)
	return c:IsCode(code) and not c:IsSetCard(0xe96)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_HAND,LOCATION_HAND,nil)
	if g:GetCount()~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		Duel.ConfirmCards(1-tc:GetControler(),tc)
		if tc:IsSetCard(0xe96) then
			Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
			Duel.ShuffleHand(tc:GetControler())
		else
			local code=tc:GetCode()
			local cg=Duel.GetMatchingGroup(s.codefilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,nil,code)
			local tc2=cg:GetFirst()
			while tc2 do
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(aux.Stringid(id,3))
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_ADD_SETCODE)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SET_AVAILABLE)
				e1:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA)
				e1:SetValue(0xe96)
				tc2:RegisterEffect(e1)
				tc2=cg:GetNext()
			end
			Duel.ShuffleHand(tc:GetControler())
		end
	end
end