--孤独摇滚 伊地知虹夏
local cm,m=GetID()

function cm.initial_effect(c)
    function cm.AddLinkProcedure(c,f,min,max,gf,string)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(string)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_EXTRA)
		if max==nil then max=c:GetLink() end
		e1:SetCondition(Auxiliary.LinkCondition(f,min,max,gf))
		e1:SetTarget(Auxiliary.LinkTarget(f,min,max,gf))
		e1:SetOperation(Auxiliary.LinkOperation(f,min,max,gf))
		e1:SetValue(SUMMON_TYPE_LINK)
		c:RegisterEffect(e1)
		return e1
	end
	function cm.AddLinkProcedure2(c,f,min,max,gf,string)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(string)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_EXTRA)
		if max==nil then max=c:GetLink() end
		e1:SetCondition(cm.LinkCondition(f,min,max,gf))
		e1:SetTarget(cm.LinkTarget(f,min,max,gf))
		e1:SetOperation(Auxiliary.LinkOperation(f,min,max,gf))
		e1:SetValue(SUMMON_TYPE_LINK)
		c:RegisterEffect(e1)
		return e1
	end
	--link summon
	cm.AddLinkProcedure(c,nil,2,2,cm.lcheck,aux.Stringid(m,7))
	cm.AddLinkProcedure2(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),2,2,cm.lcheck2,aux.Stringid(m,8))
	c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    --atkup
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(m,3))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(2,m)
	e2:SetCondition(cm.thcon)
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
    --atkup
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(m,4))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,m+EFFECT_COUNT_CODE_DUEL)
    e3:SetCondition(cm.atkcon)
	e3:SetTarget(cm.atktg)
	e3:SetOperation(cm.atkop)
	c:RegisterEffect(e3)
end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_LIGHT) or g:IsExists(Card.IsLinkRace,1,nil,RACE_FAIRY)
end

function cm.lcheck2(g)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_SPIRIT)
end

function cm.LConditionFilter(c,f,lc,e)
	return (c:IsFaceup() or not c:IsOnField() or e:IsHasProperty(EFFECT_FLAG_SET_AVAILABLE))
		and c:IsCanBeLinkMaterial(lc) and (c:IsLocation(0x04) or c:IsLinkType(TYPE_SPIRIT)) and (not f or f(c))
end

function cm.GetLinkMaterials(tp,f,lc,e)
	local mg=Duel.GetMatchingGroup(cm.LConditionFilter,tp,0x06,0,nil,f,lc,e)
	local mg2=Duel.GetMatchingGroup(Auxiliary.LExtraFilter,tp,LOCATION_HAND+LOCATION_SZONE,LOCATION_ONFIELD,nil,f,lc,tp)
	if mg2:GetCount()>0 then mg:Merge(mg2) end
	return mg
end

function cm.LinkCondition(f,minc,maxc,gf)
	return	function(e,c,og,lmat,min,max)
		if c==nil then return true end
		if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
		local minc=minc
		local maxc=maxc
		if min then
			if min>minc then minc=min end
			if max<maxc then maxc=max end
			if minc>maxc then return false end
		end
		local tp=c:GetControler()
		local mg=nil
		if og then
			mg=og:Filter(cm.LConditionFilter,nil,f,c,e)
		else
			mg=cm.GetLinkMaterials(tp,f,c,e)
		end
		if lmat~=nil then
			if not cm.LConditionFilter(lmat,f,c,e) then return false end
			mg:AddCard(lmat)
		end
		local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
		if fg:IsExists(Auxiliary.MustMaterialCounterFilter,1,nil,mg) then return false end
		Duel.SetSelectedCard(fg)
		return mg:CheckSubGroup(Auxiliary.LCheckGoal,minc,maxc,tp,c,gf,lmat)
	end
end

function cm.LinkTarget(f,minc,maxc,gf)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,lmat,min,max)
		local minc=minc
		local maxc=maxc
		if min then
			if min>minc then minc=min end
			if max<maxc then maxc=max end
			if minc>maxc then return false end
		end
		local mg=nil
		if og then
			mg=og:Filter(cm.LConditionFilter,nil,f,c,e)
		else
			mg=cm.GetLinkMaterials(tp,f,c,e)
		end
		if lmat~=nil then
			if not cm.LConditionFilter(lmat,f,c,e) then return false end
			mg:AddCard(lmat)
		end
		local fg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_LMATERIAL)
		Duel.SetSelectedCard(fg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
		local cancel=Duel.IsSummonCancelable()
		local sg=mg:SelectSubGroup(tp,Auxiliary.LCheckGoal,cancel,minc,maxc,tp,c,gf,lmat)
		if sg then
			sg:KeepAlive()
			e:SetLabelObject(sg)
			return true
		else return false end
	end
end

function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end

function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(m) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not re:GetHandler():IsCode(m)
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    Duel.RegisterFlagEffect(0,m,0,0,1)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0x04,0,1,1,nil)
	if #g>0 then
        Duel.HintSelection(g)
        local tc=g:GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(400)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
	end
end

function cm.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(0,m)>=3
end

function cm.tgafilter(c)
    return c:IsLink(2) and c:IsFaceup()
end

function cm.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tgafilter,tp,0x04,0x04,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,nil)
end

function cm.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,cm.tgafilter,tp,0x04,0x04,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
        local tc=g:GetFirst()
		local off=1
        local ops={}
        local opval={}
        if tc:GetAttack()>0 then
            ops[off]=aux.Stringid(m,0)
            opval[off-1]=1
            off=off+1
        end
		ops[off]=aux.Stringid(m,1)
		opval[off-1]=2
		off=off+1
		ops[off]=aux.Stringid(m,2)
		opval[off-1]=3
		off=off+1
        if off==1 then return end
        local op=Duel.SelectOption(tp,table.unpack(ops))
        if opval[op]==1 then
            Duel.Recover(tp,tc:GetAttack()//2,REASON_EFFECT)
        elseif opval[op]==2 then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetRange(LOCATION_MZONE)
            e1:SetValue(700)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        elseif opval[op]==3 then
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(aux.Stringid(m,5))
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
            e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetCountLimit(1)
            e1:SetRange(LOCATION_MZONE)
            e1:SetOperation(cm.atkup)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
	end
end

function cm.atkup(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetHandler()
    local e1=Effect.CreateEffect(tc)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(500)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
end