-- 鬼八仙·八鬼聚魂 (ID:99849223)
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,99849227)
	c:EnableReviveLimit()

	
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)

	
	local e_no=Effect.CreateEffect(c)
	e_no:SetType(EFFECT_TYPE_SINGLE)
	e_no:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e_no:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e_no:SetValue(1)
	c:RegisterEffect(e_no)

	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(s.fcondition)
	e1:SetOperation(s.foperation)
	c:RegisterEffect(e1)

	
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1)
	e2:SetCondition(s.effcon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)

	
	local e_atk=Effect.CreateEffect(c)
	e_atk:SetType(EFFECT_TYPE_SINGLE)
	e_atk:SetCode(EFFECT_SET_ATTACK)
	e_atk:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e_atk:SetRange(LOCATION_MZONE)
	e_atk:SetCondition(s.effcon)
	e_atk:SetValue(s.atkval)
	c:RegisterEffect(e_atk)
	local e_def=e_atk:Clone()
	e_def:SetCode(EFFECT_SET_DEFENSE)
	e_def:SetValue(s.defval)
	c:RegisterEffect(e_def)

	
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end

-- ====================
function s.ffilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeFusionMaterial()
end

function s.fcheck(sg,fc,tp,gc,chkf)
	if #sg~=8 then return false end
	if gc and not sg:IsContains(gc) then return false end
	if sg:GetClassCount(Card.GetCode)~=8 then return false end
	if not aux.MustMaterialCheck(sg,tp,EFFECT_MUST_BE_FMATERIAL) then return false end
	if not (chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,sg,fc)>0) then return false end
	return true
end

function s.fcondition(e,g,gc,chkf)
	local tp=e:GetHandlerPlayer()
	if g==nil then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) end
	local c=e:GetHandler()
	local mg=g:Filter(s.ffilter,nil,c)
	if gc and not mg:IsContains(gc) then return false end
	return mg:CheckSubGroup(s.fcheck,8,8,c,tp,gc,chkf)
end

function s.foperation(e,tp,eg,ep,ev,re,r,rp,gc,chkf)
	local c=e:GetHandler()
	local mg=eg:Filter(s.ffilter,nil,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local g=mg:SelectSubGroup(tp,s.fcheck,false,8,8,c,tp,gc,chkf)
	Duel.SetFusionMaterial(g)
end

-- ====================
function s.material_ok(c)
	local mg=c:GetMaterial()
	if #mg~=8 then return false end
	if mg:GetClassCount(Card.GetCode)~=8 then return false end
	if not mg:IsExists(Card.IsRace,8,nil,RACE_ZOMBIE) then return false end
	return mg:IsExists(function(tc) return aux.IsCodeListed(tc,99849227) end,8,nil)
end

function s.effcon(e)
	return s.material_ok(e:GetHandler())
end

-- ========== ① ==========
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

-- ========== ② ==========
function s.atkval(e,c)
	local mg=c:GetMaterial()
	local total=0
	for tc in aux.Next(mg) do
		total=total+tc:GetAttack()
	end
	return total
end

function s.defval(e,c)
	local mg=c:GetMaterial()
	local total=0
	for tc in aux.Next(mg) do
		total=total+tc:GetDefense()
	end
	return total
end

-- ========== ③  ==========
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainNegatable(ev) and s.material_ok(e:GetHandler())
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.NegateActivation(ev) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end