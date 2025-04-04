--魂之堕 救济
function c38030080.initial_effect(c)
	c:SetUniqueOnField(1,1,38030080)
	c:EnableReviveLimit()
	--cannot special summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c38030080.sprcon)
	e1:SetTarget(c38030080.sprtg)
	e1:SetOperation(c38030080.sprop)
	c:RegisterEffect(e1)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c38030080.atkval)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,38030080)
	e3:SetCondition(c38030080.descon)
	e3:SetTarget(c38030080.destg)
	e3:SetOperation(c38030080.desop)
	c:RegisterEffect(e3)
--召唤词
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,38030080+10000)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetOperation(c38030080.cop)
	c:RegisterEffect(e4)
	end
function c38030080.cop(e,tp,eg,ep,ev,re,r,rp)
	Debug.Message("被因果纠缠的少女啊，将森罗万象纳入名为救济的幻想！")
	Debug.Message("于背叛的谎言中显现那巨大的身姿吧！魂之堕 救济")
end
function c38030080.gcheck(sg,tp)
	return aux.mzctcheckrel(sg,tp) and sg:IsExists(Card.IsCode,1,nil,38030060)
end
function c38030080.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp)
	return rg:CheckSubGroup(c38030080.gcheck,3,3,tp)
end
function c38030080.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetReleaseGroup(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=rg:SelectSubGroup(tp,c38030080.gcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function c38030080.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
function c38030080.atkval(e,c)
	return Duel.GetFieldGroupCount(0,LOCATION_GRAVE,LOCATION_GRAVE)*400
end
function c38030080.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) or c:IsReason(REASON_BATTLE)
end
function c38030080.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(0,LOCATION_ONFIELD,LOCATION_ONFIELD)>0 end
	local sg=Duel.GetFieldGroup(0,LOCATION_ONFIELD,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
function c38030080.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetFieldGroup(0,LOCATION_ONFIELD,LOCATION_ONFIELD)
	Duel.Destroy(sg,REASON_EFFECT)
end
